To use the backend:
- 
- set to directory "backend"
- run "pip install -r requirement.txt"
- run "uvicorn fastApiProject.main:app --reload"
- hopefully, there should be no errors

While developing:
- 
- If you installed a new library, run: pip freeze > requirements.txt
- Check if you are pushing to the correct branch
- Try not to push too many files in 1 commit


For connection with firebase in flutter:
-
- run npm install -g firebase-tools
- run firebase login
- From any directory run this command:
- dart pub global activate flutterfire_cli
- if this does not work add this to env variables.
- Then, at the root of your Flutter project directory, run this command:
flutterfire configure --project=yoldas-73fe5

- then run flutterfire configure
- choose yoldas from projects

- then run flutter pub add firebase_core

- go to users then main user in your computer

- open terminal in there

- For windows:
run keytool -list -v -keystore  "your path to this folder\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

- go to android_app in firebase console
- add fingerprint
- copy the SHA1 key from the terminal add it
- copy the SHA256 key from the terminal add it
- run flutterfire config
- run flutter clean
- run flutter pub get

