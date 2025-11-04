# Quick Start Guide - Credit Journey Dashboard

## Option 1: React App (Recommended)

### Prerequisites
- Node.js 16+ and npm installed

### Steps

1. **Install dependencies:**
   ```bash
   cd web-dashboard
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm run dev
   ```

3. **Open in browser:**
   - The dashboard will automatically open at `http://localhost:3000`
   - Or manually navigate to that URL

### Using Makefile (from project root)
```bash
# Install dependencies
make dashboard-install

# Start dashboard
make dashboard
```

## Option 2: Standalone HTML (No Installation Required)

If you don't want to install Node.js, you can use the standalone HTML version:

1. **Open the standalone file:**
   - Navigate to `web-dashboard/standalone.html`
   - Open it in any modern web browser (Chrome, Firefox, Safari, Edge)

2. **That's it!** The dashboard will work with all features:
   - Credit score display
   - Score breakdown
   - Milestones and badges
   - Parent mode toggle

## Features to Test

### For Teens:
1. View current credit score (742)
2. See how score is calculated (4 factors)
3. Check achieved milestones
4. Track progress toward new milestones

### For Parents:
1. Toggle "Parent Mode" switch (top right of sidebar)
2. View detailed insights about:
   - Spending patterns
   - Savings behavior
   - Merchant diversity
   - Financial education
3. See recommendations for improving credit

## Mock Data

The dashboard uses mock data from `public/mockCreditData.json`. You can:
- Edit this file to test different scenarios
- See how the UI updates with different scores
- Test parent mode insights

## Validation Checklist

Use this dashboard to validate:
- [ ] Do users check the dashboard frequently?
- [ ] Are users sharing screenshots?
- [ ] Does credit transparency increase engagement?
- [ ] Which credit-scoring signals do users understand?
- [ ] Does parent mode provide value?

## Next Steps

Once validated, you can:
1. Integrate with backend API to fetch real credit data
2. Connect to Firebase for real-time updates
3. Link to blockchain for NFT credit score verification
4. Add analytics to track dashboard usage

## Troubleshooting

**Dashboard won't start:**
- Make sure Node.js is installed: `node --version`
- Try reinstalling: `rm -rf node_modules && npm install`

**Port 3000 already in use:**
- Kill the process: `lsof -ti:3000 | xargs kill -9`
- Or change port in `vite.config.js`

**Standalone HTML not working:**
- Make sure you're opening the file directly (file:// protocol is fine)
- Try a different browser
- Check browser console for errors

