# Flutter Authentication App

## Project Overview

This is a Flutter authentication application demonstrating a clean MVC (Model-View-Controller) architecture with elegant login and registration screens.

## Features

- Elegant, gradient-based UI design
- Login and Registration views
- Form validation
- Error handling
- Simulated authentication service

## Project Structure

```
lib/
│
├── models/
│   ├── user_model.dart      # User data model
│   └── auth_model.dart      # Authentication status model
│
├── views/
│   ├── login_view.dart      # Login screen UI
│   └── register_view.dart   # Registration screen UI
│
├── controllers/
│   └── auth_controller.dart # Handles authentication logic
│
├── services/
│   └── auth_service.dart    # Simulates authentication calls
│
└── main.dart                # App entry point
```

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

## Authentication Flow

- User can navigate between Login and Registration screens
- Input validation for email, password, and username
- Simulated authentication process
- Error dialogs for invalid inputs

## Customization

- Replace authentication service with your actual backend
- Modify UI colors and styles in respective view files
- Add more robust error handling and validation

## Dependencies

- Flutter SDK
- No external authentication libraries used (for demonstration)

## TODO

- Implement actual backend authentication
- Add password reset functionality
- Implement secure token management
- Add more comprehensive error handling

## Screenshots

[Add screenshots of login and registration screens]

## License

MIT License