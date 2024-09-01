***FDA RECALL ALERT***

Overview
The FDA Recall Alert is a Flutter-based mobile application designed to help users stay informed about food and product recalls issued by the U.S. Food and Drug Administration (FDA). This app provides real-time information on recalls, allows users to maintain a personal watchlist, and offers AI-powered insights on the potential effects of consuming recalled items.
*Features*
1. FDA Recall Information

Fetches and displays up-to-date information on recalls issued by the FDA
Provides detailed information about each recall, including affected products and reasons for the recall

2. User Watchlist

Allows users to create and manage a personal watchlist of items they want to monitor
Notifies users if any item on their watchlist is added to the FDA recall list

3. Product Scanner

Incorporates text scanner to quickly check if a product is on the FDA recall list
Provides instant results, allowing users to make informed decisions while shopping

4. Automated Background Checks

Utilizes Google Cloud Scheduler to run a cloud function daily
Automatically checks user-uploaded items and watchlists against the latest FDA recall list
Sends notifications to users if any of their items are found on the recall list

5. AI-Powered Insights

Integrates Gemini AI to provide additional information on the potential effects of consuming recalled items
Offers personalized explanations based on the specific reason for the recall

Technical Stack

Frontend: Flutter
Backend: Google Cloud Functions
Scheduler: Google Cloud Scheduler
AI Integration: Gemini AI
Database: [Firestore Database]


Setup Instructions
Prerequisites
Flutter SDK
Firebase account (for cloud functions)
Google Cloud account (for scheduling tasks and managing cloud functions)

**Installation**
**Clone the Repository:**

git clone [(https://github.com/Wairioko/FDA-Recall-Alert.git)]


**Install Dependencies:**
 - flutter pub get

**Set Up Firebase and Google Cloud:**
Connect your Flutter app to Firebase by creating a project in the Firebase console.
Set up Google Cloud Functions and Scheduler within your Firebase project.

**Set up any necessary configurations for Gemini AI.**
Running the App
Start the Flutter App:

 - flutter run

*Monitor Cloud Functions:*
Ensure that the Google Cloud Scheduler is set up and properly triggering the Cloud Function.
the cloud function is under the file(cloud-function.py) upload that code to google cloud function

Contributing
I welcome contributions to this project. Please submit a pull request with a detailed description of the changes and ensure your code adheres to the project's style guidelines.

License
This project is licensed under the Eclipse Public License - v 2.0.

Contact
For any queries or issues, please reach out to charlesmungai5@gmail.com








