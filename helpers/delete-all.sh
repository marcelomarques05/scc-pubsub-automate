#!/bin/bash

ORG_ID=$(gcloud organizations list --filter="gftamericas.dev" --format 'value(ID)')
PROJECT_ID="zebra-scc-workshop"
# Storage
BUCKET_NAME="my-secure-bucket"
# Pub/Sub
TOPIC_ID="scc-sa-leaked-topic"
SUBSCRIPTION_ID="scc-sa-leaked-sub"
# SCC
SCC_NOTIFICATION_ID="scc-sa-leaked-filter"
# Functions
FUNCTION_ID="rotake_sa_keys"
# Service Account
SA_ID="my-insecure-sa"

# Set Project
gcloud config set project "${PROJECT_ID}"

sa(){
    if gcloud iam service-accounts list | grep ${SA_ID}; then
        gcloud iam service-accounts delete ${SA_ID}
    else
        echo "SA ${SA_DISPLAY_NAME} not found."
    fi
}

pubsub(){
    # Create PubSub Subscription
    if gcloud pubsub subscriptions list | grep ${TOPIC_ID}; then
        gcloud pubsub subscriptions delete ${SUBSCRIPTION_ID}
    else
        echo "Subscription ${SUBSCRIPTION_ID} not found."
    fi

    # Create PubSub Topic
    if gcloud pubsub topics list | grep ${TOPIC_ID}; then
        gcloud pubsub topics delete "projects/${PROJECT_ID}/topics/${TOPIC_ID}"
    else
        echo "Topic ${TOPIC_ID} not found."
    fi
}

scc(){
    # SCC Notifications Create
    if gcloud scc notifications list ${ORG_ID} | grep ${SCC_NOTIFICATION_ID}; then
    # Delete SCC Notifications
    gcloud scc notifications delete --quiet ${SCC_NOTIFICATION_ID} --organization ${ORG_ID}
    else
        echo "SCC Notification ${SCC_NOTIFICATION_ID} not found."
    fi
}

functions(){
    # Deploy Function
    if gcloud functions list | grep ${FUNCTION_ID}; then
        gcloud functions delete --quiet ${FUNCTION_ID}
    else
        echo "Function ${FUNCTION_ID} not found."
    fi
}

sa(){
    if gcloud iam service-accounts list | grep ${SA_ID}; then
        gcloud iam service-accounts delete "${SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com" --quiet
    else
        echo "SA ${SA_ID} not found."
    fi
    if [ -f "../sa-key.json" ]; then
        rm -f ../sa-key.json
    else
        echo "SA Key not found."
    fi
}

bucket(){
    if gsutil ls | grep ${BUCKET_NAME}; then
        gsutil -m rm -r gs://${BUCKET_NAME}
#        gsutil rb gs://${BUCKET_NAME}
    else
        echo "Bucket ${BUCKET_NAME} not found."
    fi
}

functions
scc
pubsub
sa
bucket

git add -A
git commit -m"Delete SA Json File"
git push
