# Google Play Console Complete Deployment & Submission Guide

**Application Name**: FacePay: Face Liveness UPI  
**Package Name**: `com.facepay.app.facepay`  
**Developers**: Aditya Veena Maharaj & Gaurav Mudgal  
**Faculty Guide**: Dr. Gaurav Raj (Dept. of CSE, Sharda University)  
**Release Artifact**: `build/app/outputs/bundle/release/app-release.aab` (Digitally Signed, 68.5 MB)

---

## 1. Store Listing Metadata (Copy & Paste directly into Play Console)

### **App Name** (Max 30 characters)
```text
FacePay: Face Liveness UPI
```

### **Short Description** (Max 80 characters)
```text
Secure on-device facial liveness verification for UPI payments above ₹500.
```

### **Full Description** (Max 4000 characters)
```text
FacePay is a privacy-first mobile payment security application designed to protect Unified Payments Interface (UPI) users from unauthorized transactions, shoulder surfing, and phone-theft financial fraud.

Traditional digital payment systems authorize transactions using a 4- or 6-digit MPIN. If an attacker observes your PIN or snatches an unlocked device, substantial sums can be drained before the bank account can be frozen. FacePay solves this vulnerability by introducing an automated, intelligent biometric barrier.

CORE FEATURES & SECURITY ARCHITECTURE:

• Smart ₹500 Threshold Rule:
To preserve everyday payment speed, micro-transactions of ₹500 or less (such as campus cafeteria, transit, and small merchant purchases) process immediately without biometric interruption. Any transaction exceeding ₹500 strictly enforces active on-device facial liveness verification before authorization.

• Google ML Kit On-Device Liveness Verification:
FacePay performs high-speed, local computer vision analysis directly on the device using Google ML Kit Face Detection. Verification challenges require real-time cognitive responses, including randomized eye-blinking and head-turning (Euler angle yaw tracking), preventing 2D printed photo and recorded video replay attacks.

• 100% Privacy-Preserving Architecture:
No facial imagery, biometric vectors, or video streams are ever recorded, uploaded to cloud servers, or transmitted over the network. All computer vision inference executes strictly inside volatile device RAM and is purged the instant verification concludes.

• Real-Time Cloud Firestore Synchronization:
Completed transactions, security achievements, and digital balances sync seamlessly to Google Cloud Firestore, providing an immutable audit trail and security streak rewards.

• Offline-First Resilience:
FacePay caches transaction records locally using Android SharedPreferences, ensuring uninterrupted operation and audit logs even in low-connectivity environments.

DISCLAIMER:
FacePay is an academic capstone demonstration prototype developed at Sharda University (PBL-3 Course CSP-391). It illustrates a client-side biometric verification layer for digital payments and does not process real banking transactions or connect to NPCI production banking switches.
```

---

## 2. Store Listing Graphical Assets Ready in `play_store_assets/`

| Asset | Specifications | File Location |
| :--- | :--- | :--- |
| **App Icon** | 512 x 512 px, 32-bit PNG, max 1MB | `play_store_assets/icon_512.png` |
| **Feature Graphic** | 1024 x 500 px, 24-bit PNG (no alpha) | `play_store_assets/feature_graphic_1024x500.png` |
| **Phone Screenshot 1** | 1080 x 2280 px PNG | `play_store_assets/screenshot_1_secure_digital_wallet.png` |
| **Phone Screenshot 2** | 1080 x 2280 px PNG | `play_store_assets/screenshot_2_₹500_threshold_rule.png` |
| **Phone Screenshot 3** | 1080 x 2280 px PNG | `play_store_assets/screenshot_3_on-device_ml_kit_face_verification.png` |
| **Phone Screenshot 4** | 1080 x 2280 px PNG | `play_store_assets/screenshot_4_real-time_cloud_firestore_sync.png` |

---

## 3. Mandatory Policies & Questionnaires Guide

### **A. Privacy Policy**
* **Privacy Policy URL**:
  `https://facepayapplication1.vercel.app/privacy-policy`

### **B. App Access (Reviewer Instructions)**
* Select: **"All functionality is available without special credentials"**
* If asked for notes, enter:
  *Demo account pre-loaded with ₹25,000 demonstration balance. For facial verification testing above ₹500, a built-in 'Simulate Pass' button is available on the camera screen for testing environments.*

### **C. Ads**
* Select: **"No, my app does not contain ads"**

### **D. Content Rating (IARC)**
* Category: **Utility / Productivity / Financial Demonstration**
* Violence, sexual content, profanity, controlled substances: **No to all**
* Resulting Rating: **PEGI 3 / Everyone (All Ages)**

### **E. Target Audience & Content**
* Target age group: **18 and over**
* Appeal to children: **No**

### **F. News / COVID-19 / Government Apps**
* News App: **No**
* COVID-19 Contact Tracing: **No**
* Government App: **No**

### **G. Financial Features Declaration**
* Does your app provide financial features? **Yes**
* Select: **"Other financial features"**
* Explanation: *Capstone academic prototype demonstrating on-device facial biometric authorization for digital payments using simulated wallet data.*

### **H. Data Safety Questionnaire**
* **Does your app collect or share user data?** Select **Yes**
* **Is all of the user data collected by your app encrypted in transit?** Select **Yes** (HTTPS/TLS via Firebase)
* **Do you provide a way for users to request data deletion?** Select **Yes** (Users can reset demo data and clear history via in-app Settings)
* **Data Types Collected**:
  1. **Photos and Videos**:
     * Data is collected? Select **No**.
     * Data is processed ephemerally? Select **Yes** (Camera is used on-device for live face detection without storing or uploading images).
  2. **Financial Info (In-app purchase/payment history)**:
     * Collected? Select **Yes** (Simulated transaction history saved in Cloud Firestore).
     * Shared? Select **No**.
     * Purpose: **App functionality / Account management**.
  3. **Personal Info (Name / User ID)**:
     * Collected? Select **Yes** (Profile display name `Aditya Veena Maharaj`).
     * Purpose: **Personalization / App functionality**.

---

## 4. Release Signing Details

* **Keystore File**: `android/app/facepay-upload.jks` (2048-bit RSA)
* **Key Alias**: `facepay-upload-key`
* **Validity**: Until April 7, 2054
* **SHA-1 Fingerprint**:
  `5E:2F:87:06:06:B7:44:D4:27:31:84:AD:82:80:AA:75:A7:43:AB:AB`
* **SHA-256 Fingerprint**:
  `05:BA:E0:13:5E:0F:0F:16:0E:F3:37:7A:92:E0:E8:05:D4:EC:A4:FF:8A:80:6B:00:06:EE:05:FE:96:B9:26:DB`
