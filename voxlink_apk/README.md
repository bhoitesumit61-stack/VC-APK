# VoxLink Flutter APK

This is the mobile version of the VoxLink Premium Voice Chat.

## Features
- **Premium UI**: Black & White theme with mesh gradients and glassmorphism.
- **High Fidelity**: Powered by LiveKit for low-latency voice communication.
- **Encrypted**: Secure signaling and AES-256 audio encryption.
- **Automated Build**: GitHub Actions workflow included for easy APK generation.

## How to Build the APK on GitHub

1. **Push to your Repository**:
   - Upload all the files in this folder to your repository: `https://github.com/bhoitesumit61-stack/VC-APK`.
   - Ensure the `.github/workflows/build-apk.yml` file is in the correct path.

2. **Wait for the Build**:
   - Go to the **Actions** tab in your GitHub repository.
   - You will see a workflow named **Build APK** running.
   - Once it completes, you can download the APK from the **Artifacts** section of the run.

3. **Configure LiveKit**:
   - The app is currently configured to use your LiveKit URL: `wss://wasd-9bjnbp7j.livekit.cloud`.
   - Ensure your backend (e.g., `https://vcrepo.vercel.app`) is running to provide JWT tokens.

## Configuration
In `lib/main.dart`, you can update the following:
- `url`: Your LiveKit server URL.
- Token fetching logic: Update the `_connectToRoom` method to point to your backend API.

## Credits
Built with Flutter and LiveKit.
Designed by Antigravity.
