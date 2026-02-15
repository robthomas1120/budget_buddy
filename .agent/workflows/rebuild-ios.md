---
description: How to update and rebuild the iOS app for your iPhone
---

1. **Stop the current Expo server** (if running) in your terminal by pressing `Ctrl + C`.

2. **Update JavaScript dependencies**:
```bash
npm install
```

3. **Update Native modules**:
```bash
npx expo prebuild
cd ios && pod install && cd ..
```

4. **Open the project in Xcode**:
```bash
open ios/budgetbuddytemp.xcworkspace
```

5. **In Xcode**:
   - Select your **iPhone** as the target device in the top toolbar.
   - Press **Cmd + Shift + K** to clean the build folder.
   - Press **Cmd + R** to build and run the app on your iPhone.

6. **Start the Expo development server**:
```bash
npx expo start --dev-client
```
Ensure your iPhone and Mac are on the same Wi-Fi network.
