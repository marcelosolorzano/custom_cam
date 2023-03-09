<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Custom Camera Plugin

[![pub package](https://img.shields.io/pub/v/custom_cam.svg)](https://pub.dev/packages/custom_cam)

A Flutter plugin for iOS and Android to allow an easy custom UI camera set-up with photo and video capabilites that stores files locally internal to the app and returns its path and media type.

|                | Android | iOS      |
|----------------|---------|----------|
| **Support**    | SDK 21+ | iOS 10+* |

## Features

* Camera permission exception handling.
* Display live camera preview.
* Device orientation responsive UI.
* Record video.
* Take photos.
* Zoom with gestures.
* Persistant storage trough app files.

## Getting started

First, add `custom_cam` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### iOS

\* The camera plugin compiles for any version of iOS, but its functionality
requires iOS 10 or higher. If compiling for iOS 9, make sure to programmatically
check the version of iOS running on the device before using any camera plugin features.
The [device_info_plus](https://pub.dev/packages/device_info_plus) plugin, for example, can be used to check the iOS version.

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

### Android

Change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle` file.

```groovy
minSdkVersion 21
```

## Usage

Here is a small example of a flutter app that opens the camera and waits for the camera result. MultimediaItem is a package class with two parameters: one for the storage path and another to differentiate between video and photo.

```dart
final MultimediaItem? result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CustomCamera(
            primaryColor: Color(0xff000fff), 
            secondaryColor: Color(0xfffff0fff), 
            backgroundColor: Color(0xff000faa)
        ))
);
```

## Additional information

For a more elaborate usage example see [here](https://github.com/marcelosolorzano/custom_cam/tree/main/example).
