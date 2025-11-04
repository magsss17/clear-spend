# Credit Journey Dashboard

A React-based web dashboard for ClearSpend that provides transparency around how a teen's credit NFT score evolves.

## Features

- **Current Credit Score Display**: Shows the teen's current credit score with visual progress indicator
- **Score Breakdown**: Detailed breakdown of how the score is calculated:
  - Spending Consistency (35% weight)
  - Savings Rate (30% weight)
  - Merchant Diversity (25% weight)
  - Financial Education (10% weight)
- **Milestones & Badges**: Track progress toward achievements like:
  - "3 weeks of responsible spending"
  - "First round-up savings completed"
  - "Credit Elite" (750+ score)
  - And more...
- **Parent Mode Toggle**: Parents can enable a special view to see:
  - Detailed insights about credit score factors
  - Behavioral recommendations
  - What affects the score positively/negatively

## Getting Started

### Prerequisites

- Node.js 16+ and npm

### Installation

```bash
cd web-dashboard
npm install
```

### Running the Dashboard

```bash
npm run dev
```

The dashboard will open at `http://localhost:3000`

### Building for Production

```bash
npm run build
```

The built files will be in the `dist/` directory.

## Project Structure

```
web-dashboard/
├── public/
│   └── mockCreditData.json    # Mock data for credit score
├── src/
│   ├── components/
│   │   ├── CreditJourneyDashboard.jsx
│   │   ├── ScoreDisplay.jsx
│   │   ├── BreakdownSection.jsx
│   │   ├── MilestonesSection.jsx
│   │   └── ParentInsightsToggle.jsx
│   ├── App.jsx
│   ├── main.jsx
│   └── index.css
├── index.html
├── package.json
└── vite.config.js
```

## Mock Data

The dashboard currently uses mock data from `public/mockCreditData.json`. This file contains:

- Current credit score and range
- Detailed breakdown by category
- Milestones (achieved and in-progress)
- Recent activity log
- Parent insights (when parent mode is enabled)

## Features in Detail

### Credit Score Breakdown

Each factor shows:
- Current score out of maximum
- Weight percentage (how much it contributes)
- Progress bar visualization
- Detailed factors (when parent mode is enabled)

### Milestones

Milestones are displayed in two sections:
- **Achieved**: Badges that have been unlocked
- **In Progress**: Goals with progress tracking

Each milestone shows:
- Icon and title
- Description
- Progress (for pending milestones)
- Points awarded

### Parent Mode

When enabled, parents can see:
- Detailed breakdowns of each credit factor
- Specific behaviors that affect the score
- Recommendations for improving credit
- Insights about spending patterns, savings, and education

## Validation & Testing

This dashboard is designed to help validate:

1. **User Engagement**: Track how frequently users check the dashboard
2. **Transparency Impact**: Measure if credit transparency increases engagement
3. **Retention Intent**: See if users share screenshots or discuss the feature
4. **Understanding**: Get feedback on which credit-scoring signals users understand

## Future Integration

Currently uses mock data. Future integration points:
- Connect to backend API to fetch real credit data
- Integrate with Firebase for real-time updates
- Link to blockchain for NFT credit score verification
- Add user analytics to track dashboard usage

## Design Notes

The dashboard follows ClearSpend's design language:
- Purple accent color (#8b5cf6)
- Clean white cards with subtle shadows
- Responsive design for mobile and desktop
- Modern, teen-friendly UI

## License

MIT License - Part of ClearSpend project

