def rotake_sa_keys(event, context):

    import json,base64
    import googleapiclient.discovery
    from google.cloud import storage
    from google.oauth2 import service_account

    credentials = service_account.Credentials.from_service_account_file('creds.json')
    bucket_name = "my-secure-bucket"

    if 'data' in event:
        parsed_message = json.loads(base64.b64decode(event['data']).decode('utf-8'))
        compromised_key = parsed_message["finding"]["sourceProperties"]["private_key_identifier"]
        compromised_account = parsed_message["finding"]["sourceProperties"]["compromised_account"]
        compromised_project = parsed_message["finding"]["sourceProperties"]["project_identifier"]
        summary_message = parsed_message["finding"]["sourceProperties"]["summary_message"]
        url_find = parsed_message["finding"]["sourceProperties"]["url"]
    else:
        print('No Data Was Found In Pub/Sub Message.')
        return

    print(summary_message + "\nURL: " + url_find)

    # Instantiate IAM
    service = googleapiclient.discovery.build('iam', 'v1', credentials=credentials, cache_discovery=False)

    # Create new Key
    key = service.projects().serviceAccounts().keys().create(name='projects/-/serviceAccounts/' + compromised_account, body={}).execute()
    print('New key created.')

    # Delete Compromised Key
    service.projects().serviceAccounts().keys().delete(name='projects/' + compromised_project + '/serviceAccounts/' + compromised_account + '/keys/' + compromised_key).execute()
    print('Deleted compromised key.')

    # Upload to Bucket
    client = storage.Client.from_service_account_json('creds.json')
    bucket = client.get_bucket(bucket_name)
    blob = bucket.blob('sa-key.json')
    blob.upload_from_string(json.dumps(key))
    print("New key file uploaded to {}.".format(bucket_name))

if __name__ == "__main__":
    rotake_sa_keys("event", "context")
