# smartwardrobe

Smart wardrobe management app with AI outfit suggestions.

## Project Structure

```
smartwardrobe/
├── frontend/          # Flutter mobile app
│   ├── lib/           # App source code (models, screens, widgets, utils)
│   ├── assets/        # Static assets (images)
│   ├── android/       # Android platform code
│   ├── ios/           # iOS platform code
│   ├── web/           # Web platform code
│   ├── windows/       # Windows platform code
│   ├── linux/         # Linux platform code
│   ├── macos/         # macOS platform code
│   ├── test/          # Flutter tests
│   └── pubspec.yaml   # Flutter dependencies
│
├── backend/           # Dart/Shelf backend server
│   ├── lib/           # Server source code (routes, middleware, models)
│   └── pubspec.yaml   # Server dependencies
│
├── firebase.json      # Firebase configuration
├── firestore.indexes.json
├── firestore.rules    # Firestore security rules
└── README.md
```

## Getting Started

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

### Backend
```bash
cd backend
dart pub get
dart run lib/main.dart
```
