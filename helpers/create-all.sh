#!/bin/bash

# Edit From Here
DOMAIN="yourdomain.com"
PROJECT_ID="project-XXXX"
BUCKET_NAME="my-secure-bucket"
PUBSUB_TOPIC_ID="scc-sa-leaked-topic"
PUBSUB_SUBSCRIPTION_ID="scc-sa-leaked-sub"
SCC_NOTIFICATION_ID="scc-sa-leaked-filter"
SCC_DESCRIPTION="Filter for Leaked Accounts"
SCC_FILTER="(category = \"account_has_leaked_credentials\") AND state = \"ACTIVE\""
FUNCTION_ID="rotake_sa_keys"
FUNCTION_REGION="us-central1"
FUNCTION_RUNTIME="python37"
FUNCTION_SOURCE="../functions/"
SA_ID="my-insecure-sa"
SA_DESCRIPTION="SA for Security Tests Only. DO NOT ADD ANY ROLE."
# Edit Until Here

ORG_ID=$(gcloud organizations list --filter="${DOMAIN}" --format 'value(ID)')

# Set Project
gcloud config set project "${PROJECT_ID}"

sa(){
    if ! gcloud iam service-accounts list | grep ${SA_ID}; then
        gcloud iam service-accounts create ${SA_ID} \
        --description="${SA_DESCRIPTION}" \
        --display-name="${SA_ID}"
    else
        echo "SA ${SA_ID} already exists."
    fi
    if ! [ -f "../sa-key.json" ]; then
        gcloud iam service-accounts keys create "../sa-insecure-key.json" \
        --iam-account="${SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
    else
        echo "SA Key already exist."
    fi
}

pubsub(){
    # Create PubSub Topic
    if ! gcloud pubsub topics list | grep ${PUBSUB_TOPIC_ID}; then
        gcloud pubsub topics create ${PUBSUB_TOPIC_ID}
    else
        echo "Topic ${PUBSUB_TOPIC_ID} already created."
    fi

    # Create PubSub Subscription
    if ! gcloud pubsub subscriptions list | grep ${PUBSUB_TOPIC_ID}; then
        gcloud pubsub subscriptions create ${PUBSUB_SUBSCRIPTION_ID} \
        --topic projects/${PROJECT_ID}/topics/${PUBSUB_TOPIC_ID}
    else
        echo "Subscription ${PUBSUB_SUBSCRIPTION_ID} already created."
    fi
}

scc(){
    # SCC Notifications Create
    if ! gcloud scc notifications list ${ORG_ID} | grep ${SCC_NOTIFICATION_ID}; then
        gcloud scc notifications create ${SCC_NOTIFICATION_ID} \
        --organization "${ORG_ID}" --description "${SCC_DESCRIPTION}" \
        --pubsub-topic "projects/${PROJECT_ID}/topics/${PUBSUB_TOPIC_ID}" \
        --filter "${SCC_FILTER}"
    else
        echo "SCC Notification ${SCC_NOTIFICATION_ID} already created."
    fi
}

functions(){
    # Deploy Function
    if ! gcloud functions list | grep ${FUNCTION_ID}; then
        gcloud functions deploy ${FUNCTION_ID} --region=${FUNCTION_REGION} \
        --runtime=${FUNCTION_RUNTIME} --source=${FUNCTION_SOURCE} \
        --trigger-topic=${PUBSUB_TOPIC_ID}
    else
        echo "Function ${FUNCTION_ID} already created."
    fi
}

bucket(){
    # Create Bucket
    if ! gsutil ls | grep ${BUCKET_NAME}; then
        gsutil mb gs://${BUCKET_NAME}
    else
        echo "Bucket ${BUCKET_NAME} already exists."
    fi
}

sa
pubsub
scc
functions
bucket
