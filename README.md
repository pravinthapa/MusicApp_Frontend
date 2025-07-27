# finalmicrophone
To set this up, the safest way is so that the laptop doesn't hang and you don't waste a day in it.

1. Install Android Studio.
2. Install Flutter.
3. Set the Flutter SDK path (e.g., /bin/cache/dart-SDK) in the Dart SDK settings of Android Studio.
4. Install the Flutter and Dart plugins in the Android Studio settings.
5. Clone the project.
6. Create a new Flutter project with the same name.
7. Run Gradle first to ensure it shows on the mobile (counter app).
8. Go to Tools -> SDK Manager and install the command-line tools.
9. Install Firebase CLI and perform a Firebase login (if Google auth doesn't work, reset the password using Gmail).
10. Copy the lib folder, pubspec.yml and lock file, and google.json file to the new project.
11. Run `flutter run` after closing other apps to ensure smooth execution.

Tried to apply SOLID principles to my app, but since I am using ChangeNotifier, there is no need. It is efficient as it is.

DEMO:


![Demo GIF](images/demoMajorProject.gif)