# DesafIA 

**DesafIA** is a mobile application developed in Flutter, focused on creating and solving quizzes using the power of **AI**. With the integration of the Google Generative AI API (Gemini) and Firebase, users can challenge themselves with dynamically generated questions, create their own quizzes, and track their progress intuitively.

## Key Features

- **Authentication**: User registration and login using Firebase Auth (including native support for Google Sign-In).
- **AI Quiz Creation**: Automatic creation of personalized quizzes in real-time through artificial intelligence.
- **Profile Management**: User profile editing and management.
- **Dashboard and Results**: Tracking of quiz results and detailed activity history.
- **Creation and Editing**: Users can create new quizzes, edit questions, and manage their content independently.

## Stack 

- **Framework:** [Flutter](https://flutter.dev/)
- **Backend & Database:** [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore)
- **AI:** [Google Generative AI (Gemini)](https://ai.google.dev/)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)

### Installation and Execution

1. **Clone this repository::**
   ```bash
   git clone https://github.com/seu-utilizador/DesafIA.git
   ```

2. **Navigate to the project directory:**
   ```bash
   cd desaf_i_a
   ```

3. **Install the Flutter dependencies:**
   ```bash
   flutter pub get
   ```

4. **Firebase Configuration:**
   Make sure you set up the connection to your Firebase project. You can use the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

5. **API Key Configuration (Gemini):**
   Ensure that the Google Generative AI API key is properly configured in the project environment for quiz generation to work correctly.

6. **Run the application:**
   ```bash
   flutter run
   ```



