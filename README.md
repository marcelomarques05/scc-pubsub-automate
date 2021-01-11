# SCC to PubSub Automation

## Diagram

<div style="text-align:center">

![Diagram](https://miro.medium.com/max/1244/1*2ErPpQ9asZ_pVZuXsOigPQ.png)

</div>

More info about it can be checked here:

https://medium.com/marcelo-marques/commit-a-private-key-in-github-oops-faad97e7a64d

### Create Resources

To create the resources, use the `helpers/create-all.sh` script. There's a few changes before run:

```
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
```
After all changes based in your environment, execute and all resources will be created:
- Service Account
- Pub/Sub Topic and Subscriptions
- Bucket
- SCC Notification
- Cloud Functions

To delete all resources, you can run `helpers/delete-all.sh` changing the same values.