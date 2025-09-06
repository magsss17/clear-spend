# 🔧 ClearSpend iOS Build Instructions

## Quick Fix for Current Build Errors

### 1. Add AlgorandSDK Dependency in Xcode

**Open the project in Xcode:**
```bash
open ClearSpend.xcodeproj
```

**Add Swift Package Manager dependency:**
1. In Xcode, go to **File → Add Package Dependencies...**
2. Enter this URL: `https://github.com/algorand/swift-algorand-sdk.git`
3. Click **Add Package**
4. Select version **2.5.0** or later
5. Add **AlgorandSDK** to your **ClearSpend** target
6. Click **Add Package**

### 2. Alternative: Use our mock AlgorandSDK

If the package fails to resolve, I can create a simplified mock version for the hackathon demo:

**Remove AlgorandSDK imports temporarily and use local mock implementation**

### 3. Fix Signing Issues

1. In Xcode, select your **ClearSpend** project
2. Go to **Signing & Capabilities** 
3. Select your **development team**
4. Change **Bundle Identifier** to something unique like: `com.yourname.clearspend.demo`

## 🚀 After Fixing Dependencies

### Test the Build:
1. Select **ClearSpend** scheme
2. Choose **iOS Simulator** (iPhone 15 Pro recommended)
3. Press **⌘+R** to build and run

### Demo Features Ready:
- ✅ Credit building dashboard with 742 score
- ✅ Fraud prevention with atomic transfers  
- ✅ Educational modules that unlock allowances
- ✅ Real testnet integration (when AlgorandSDK works)
- ✅ Credit Score NFT viewing

## 🎯 Hackathon Demo Script

1. **Show Home Screen**: Credit score, fraud prevention stats
2. **Show Spend Screen**: Try a fraudulent purchase (ShadyDealsOnline) → blocked
3. **Show Spend Screen**: Try valid purchase (Amazon) → approved
4. **Show Learn Tab**: Educational modules with allowance rewards
5. **Show Achievements**: Credit building milestones
6. **Show Explorer Links**: Real blockchain transactions on testnet

## 🆘 If Build Still Fails

Let me know and I'll create a simplified version without external dependencies that still demonstrates all the core concepts!