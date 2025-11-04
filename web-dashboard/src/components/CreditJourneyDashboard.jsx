import React, { useState, useEffect } from 'react'
import ScoreDisplay from './ScoreDisplay'
import BreakdownSection from './BreakdownSection'
import MilestonesSection from './MilestonesSection'
import ParentInsightsToggle from './ParentInsightsToggle'
import './CreditJourneyDashboard.css'

function CreditJourneyDashboard() {
  const [creditData, setCreditData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [parentMode, setParentMode] = useState(false)

  useEffect(() => {
    // Load mock data from JSON file
    fetch('/mockCreditData.json')
      .then(response => response.json())
      .then(data => {
        setCreditData(data)
        setLoading(false)
      })
      .catch(error => {
        console.error('Error loading credit data:', error)
        setLoading(false)
      })
  }, [])

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner"></div>
        <p>Loading your credit journey...</p>
      </div>
    )
  }

  if (!creditData) {
    return (
      <div className="dashboard-error">
        <p>Unable to load credit data. Please try again later.</p>
      </div>
    )
  }

  return (
    <div className="credit-journey-dashboard">
      <header className="dashboard-header">
        <h1>Credit Journey Dashboard</h1>
        <p className="dashboard-subtitle">Track your financial progress and build credit history</p>
      </header>

      <div className="dashboard-content">
        <div className="dashboard-main">
          <ScoreDisplay 
            score={creditData.currentScore}
            scoreRange={creditData.scoreRange}
            level={creditData.scoreLevel}
            color={creditData.scoreColor}
            recentActivity={creditData.recentActivity}
          />

          <BreakdownSection 
            breakdown={creditData.breakdown}
            parentMode={parentMode}
          />

          <MilestonesSection 
            milestones={creditData.milestones}
          />
        </div>

        <aside className="dashboard-sidebar">
          <ParentInsightsToggle 
            parentMode={parentMode}
            onToggle={setParentMode}
            insights={creditData.parentInsights}
          />
        </aside>
      </div>
    </div>
  )
}

export default CreditJourneyDashboard

