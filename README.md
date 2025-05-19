# 🎬 Movie Watchlist App

A Flutter-based mobile app allowing users to sign up, log in, and maintain their own personalized movie watchlists. Movies can be marked as watched or unwatched, rated from 1–5 stars, and each user's data is privately stored using a cloud backend (Back4App).

---

## 🚀 Features

- **User Authentication**:  
  - Secure signup & login powered by **Back4App (Parse Server)**  
  - Persistent sessions maintained securely

- **Movie Watchlist Management**:  
  - Add, update, or delete movie entries  
  - Mark movies as watched/unwatched  
  - Rate movies numerically (1–5 stars), visually displayed  
  - Filter movies by watched status (All, Watched, Unwatched)  

- **Form Validation**:
  - Numeric input validation for movie rating (1–5 stars)

- **Personalized Data**:
  - Each user maintains a private watchlist
  - Data secured & separated per user

---

## 🔧 Technologies & Tools Used

- **Frontend**: Flutter (Material 3 UI)
- **Backend**: Back4App (Parse Server)
- **Parse Flutter SDK**: [parse_server_sdk_flutter](https://pub.dev/packages/parse_server_sdk_flutter)
- **State Management**: Flutter built-in Stateful Widgets
- **Code Editor**: Visual Studio Code / Android Studio
- **Testing**: Android Emulator
- **Version Control**: Git & GitHub

---

## 📦 Database Structure (Back4App)

- **`_User`** class (default by Parse):
  | Column | Type | Description |
  |--------|------|-------------|
  | objectId | String | Unique User ID |
  | username | String | Username |
  | email | String | Email address |
  | password | String | Hashed password |
  | sessionToken | String | Authentication token |

- **`Movie`** class (custom):
  | Column | Type | Description |
  |--------|------|-------------|
  | objectId | String | Movie ID |
  | movie_title | String | Movie title |
  | watched | Boolean | Watched or not |
  | rating | Number | Numeric rating (1–5) |
  | owner | Pointer<_User> | User who created movie |

---

## 🚩 Getting Started

###  Step 1: Clone the Repository
bash
git clone <your-repo-url>
cd movie_watchlist

### Step 2: Setup Flutter Environment
Make sure Flutter is installed:

Install Flutter

Verify installation:

bash
Copy
Edit
flutter doctor


### Step 3: Install Dependencies
Run the following in the project root directory:

bash
Copy
Edit
flutter pub get


### Step 4: Configure Backend (Back4App)
Sign up at Back4App

Create a new Parse App

Create the database structure as mentioned above (_User and Movie classes)

Obtain your Application ID, Client Key, and Server URL from Back4App Dashboard → Settings → App Keys.

### Step 5: Configure App to use your Parse Backend
In lib/main.dart, update:

dart
Copy
Edit
await Parse().initialize(
  'YOUR_APP_ID',
  'https://YOUR_PARSE_SERVER_URL/parse',
  clientKey: 'YOUR_CLIENT_KEY',
  autoSendSessionId: true,
);
Replace YOUR_APP_ID, YOUR_PARSE_SERVER_URL, and YOUR_CLIENT_KEY with your actual Back4App keys.

### Step 6: Run the App
Launch emulator or connect a physical device:

bash
Copy
Edit
flutter run
