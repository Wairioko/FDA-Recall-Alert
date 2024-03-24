import firebase_admin
from firebase_admin import credentials, firestore, messaging
from google.cloud import secretmanager, storage
from datetime import datetime, timedelta
import requests
import json

# Retrieve secret from Secret Manager
client = secretmanager.SecretManagerServiceClient()
name = f"projects/529836025778/secrets/firestore-admin/versions/1" 
# Replace with your secret name

response = client.access_secret_version(name=name)
payload = response.payload.data.decode("UTF-8")

# Write credentials to a file (if required)
with open("credentials.json", "w") as f:
    f.write(payload)

# Create credentials
cred = credentials.Certificate("credentials.json")  # Use the path to the file
firebase_admin.initialize_app(cred)

# Create a reference to the Firestore database
db = firestore.client()

def fetch_food_results():
    # Define endpoint for food category
    endpoint = 'https://api.fda.gov/food/enforcement'

    # Calculate start date (5 months before today's date)
    start_date = (datetime.today() - timedelta(days=150)).strftime('%Y%m%d')
    # Calculate end date (today's date)
    end_date = datetime.today().strftime('%Y%m%d')

    url = f"{endpoint}.json?search=report_date:[{start_date}+TO+{end_date}]&limit=1000"

    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an exception for 4xx and 5xx status codes
        data = response.json()
        return data.get('results', [])
    except requests.exceptions.RequestException as e:
        print(f"Error fetching FDA food data:", e)
        return []

def fetch_drug_results():
    # Define endpoint for drug category
    endpoint = 'https://api.fda.gov/drug/enforcement'

    # Calculate start date (5 months before today's date)
    start_date = (datetime.today() - timedelta(days=150)).strftime('%Y%m%d')
    # Calculate end date (today's date)
    end_date = datetime.today().strftime('%Y%m%d')

    url = f"{endpoint}.json?search=report_date:[{start_date}+TO+{end_date}]&limit=1000"

    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an exception for 4xx and 5xx status codes
        data = response.json()
        return data.get('results', [])
    except requests.exceptions.RequestException as e:
        print(f"Error fetching FDA drug data:", e)
        return []

def store_results_in_storage(results):
    storage_client = storage.Client()
    bucket = storage_client.bucket('fda_data_change')
    blob = bucket.blob('results.json')
    blob.upload_from_string(json.dumps({'results': results}), content_type='application/json')
    print("Successful upload to bucket")

def fetch_device_results():
    # Define endpoint for device category
    endpoint = 'https://api.fda.gov/device/enforcement'

    # Calculate start date (5 months before today's date)
    start_date = (datetime.today() - timedelta(days=150)).strftime('%Y%m%d')
    # Calculate end date (today's date)
    end_date = datetime.today().strftime('%Y%m%d')

    url = f"{endpoint}.json?search=report_date:[{start_date}+TO+{end_date}]&limit=1000"

    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an exception for 4xx and 5xx status codes
        data = response.json()
        return data.get('results', [])
    except requests.exceptions.RequestException as e:
        print(f"Error fetching FDA device data:", e)
        return []

def get_stored_results_from_storage():
    storage_client = storage.Client()
    bucket = storage_client.bucket('fda_data_change')
    blob = bucket.blob('results.json')
    if blob.exists():
        print("extracted data from cloud storage")
        return json.loads(blob.download_as_string())['results']
    else:
        return []

def send_notifications(new_items):
    # Send notifications to users with new recall information
    registration_tokens = get_user_tokens()
    if registration_tokens:
        message = messaging.MulticastMessage(
            notification=messaging.Notification(
                title="New FDA Recall Alert",
                body=f"{len(new_items)} new recall(s) added.",
            ),
            tokens=registration_tokens,
        )
        response = messaging.send_multicast(message)
        print(f"Notification sent successfully to {response.success_count} devices.")
    else:
        print("No devices registered for notifications.")

def get_user_tokens():
    # Fetch tokens from Firestore
    users_ref = firestore.client().collection('users')
    tokens = []
    for user in users_ref.stream():
        user_data = user.to_dict()
        if 'token' in user_data:
            tokens.append(user_data['token'])
    return tokens

def compare_results(new_results, stored_results):
    new_elements = []

    # Extract event IDs from stored results
    stored_event_ids = {result['event_id'] for result in stored_results}

    for result in new_results:
        try:
            event_id = result['event_id']
            if event_id not in stored_event_ids:
                new_elements.append(result)
        except KeyError as e:
            print("KeyError:", e)
            print("Invalid result:", result)

    return new_elements

def retrieve_watchlist_items(user_id, category):
    # Retrieve watchlist items for the user and category from Firestore
    watchlist_items = []
    watchlist_ref = firestore.client().collection('watchlist').document(user_id).collection(category)
    docs = watchlist_ref.stream()
    for doc in docs:
        watchlist_items.append(doc.to_dict())
    return watchlist_items

def process_matches(results, user_id):
    user_watchlist_items_food = retrieve_watchlist_items(user_id, 'FOOD')
    user_watchlist_items_drug = retrieve_watchlist_items(user_id, 'DRUG')
    user_watchlist_items_device = retrieve_watchlist_items(user_id, 'DEVICE')

    for result in results:
        product_description = result.get('product_description', '').lower()
        for watchlist_item in user_watchlist_items_food:
            watchlist_item_description = watchlist_item.get('description', '').lower()
            if watchlist_item_description in product_description:
                send_match_notification(watchlist_item, result, user_id)
        for watchlist_item in user_watchlist_items_drug:
            watchlist_item_description = watchlist_item.get('description', '').lower()
            if watchlist_item_description in product_description:
                send_match_notification(watchlist_item, result, user_id)
        for watchlist_item in user_watchlist_items_device:
            watchlist_item_description = watchlist_item.get('description', '').lower()
            if watchlist_item_description in product_description:
                send_match_notification(watchlist_item, result, user_id)

def send_match_notification(item, result_data, user_id):
    # Implement logic to send high alert notification to the user
    user_token = get_user_token(user_id)
    if user_token:
        # Construct the notification message
        notification_message = f"POTENTIAL MATCH FOUND FOR:\n{item}"


        # Send notification using Firebase Cloud Messaging
        message = messaging.Message(
            notification=messaging.Notification(
                title="Potential Match Alert",
                body=notification_message
            ),
            token=user_token,
        )
        try:
            response = messaging.send(message)
            print(f"Notification sent successfully to user {user_id}.")
        except Exception as e:
            print(f"Error sending notification to user {user_id}: {e}")
    else:
        print(f"No token found for user {user_id}. Notification not sent.")



def get_user_token(user_id):
    # Fetch token for the user from Firestore
    user_doc_ref = firestore.client().collection('users').document(user_id)
    user_data = user_doc_ref.get().to_dict()
    return user_data.get('token', None)

def update_notification_record(user_id, item):
    # Update the notification record for the user in Firestore
    user_doc_ref = firestore.client().collection('notifications').document(user_id)
    user_notifications_ref = user_doc_ref.collection('user-notifications')

    # Check if a notification record already exists for the user and item
    existing_notifications = user_notifications_ref.where('item', '==', item).limit(1).get()

    if not existing_notifications:  # If no existing notification record
        # Create a new notification record
        notification_data = {
            'item': item,
            'timestamp': datetime.now().isoformat()
        }
        user_notifications_ref.add(notification_data)


def main():
    # Fetch results for all categories
    food_results = fetch_food_results()
    drug_results = fetch_drug_results()
    device_results = fetch_device_results()

    # Compare results with previously stored results
    stored_results = get_stored_results_from_storage()
    new_food_elements = compare_results(food_results, stored_results)
    new_drug_elements = compare_results(drug_results, stored_results)
    new_device_elements = compare_results(device_results, stored_results)

    # Store the new results for future comparison
    store_results_in_storage(food_results)

    # Send notifications for new elements
    if new_food_elements:
        send_notifications(new_food_elements)
    else:
        print("No new elements for food")

    # Process potential matches for each user
    users_ref = firestore.client().collection('users')
    for user in users_ref.stream():
        user_id = user.id
        process_matches(food_results, user_id)
        process_matches(drug_results, user_id)
        process_matches(device_results, user_id)

main()
