# macros

Experiments with upcoming Dart macros

## Setup

- Update your SDK to a dev build (this was written on 3.4.0-77.0.dev)
- For Flutter users: `flutter channel master`
- Add `--enable-experiment=macros` to `dart` invocations
- In VS Code update to the Pre-Release Dart/Flutter extensions

## @Model()

This is a replacement for the `freezed` and `json_serializable` packages.

It implements `fromJson`, `toJson`, `copyWith`, `toString`, `operator ==` and `hashCode`.

See `bin/model.dart` for an example.

See `lib/model.dart` for implementation.

## Disclaimer

I've definitely missed edge cases. Create an issue or a pull request. Do not use in production yet.
