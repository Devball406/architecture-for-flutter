# robust

robust riverpod 2.0

Features
Login
Fetch products
Search products
Pagination

## What is used in this project?
- Riverpod Used for state management
- Freezed Code generation
- Auto Route Navigation package that uses code generation to simplify route setup
- Dio Http client for dart. Supports interceptors and global configurations
- Shared Preferences Persistent storage for simple data
- Flutter and Dart And obviously flutter and dart 😅


## envied Known issues #
When modifying the .env file, the generator might not pick up the change due to dart-lang/build#967. 
If that happens simply clean the build cache and run the generator again.
`
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
`
