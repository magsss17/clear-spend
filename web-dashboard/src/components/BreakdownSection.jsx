import React from 'react'
import './BreakdownSection.css'

function BreakdownSection({ breakdown, parentMode }) {
  const categories = Object.entries(breakdown).map(([key, value]) => ({
    key,
    ...value
  }))

  const getCategoryName = (key) => {
    const names = {
      spendingConsistency: 'Spending Consistency',
      savingsRate: 'Savings Rate',
      merchantDiversity: 'Merchant Diversity',
      financialEducation: 'Financial Education'
    }
    return names[key] || key
  }

  const getCategoryIcon = (key) => {
    const icons = {
      spendingConsistency: '📊',
      savingsRate: '💾',
      merchantDiversity: '🏪',
      financialEducation: '📚'
    }
    return icons[key] || '📈'
  }

  return (
    <div className="breakdown-section">
      <h2>Credit Score Breakdown</h2>
      <p className="breakdown-subtitle">
        Your credit score is calculated from these factors:
      </p>

      <div className="breakdown-explanation">
        <h3>📖 How Your Credit Score is Calculated</h3>
        <p>
          Your credit score (out of 850) is calculated by combining four key factors, each with a specific weight:
        </p>
        <ul className="explanation-list">
          <li>
            <strong>Spending Consistency (35%)</strong> - Measures how consistently you make responsible purchases. 
            Factors include regular spending patterns, no overspending instances, and maintaining good spending streaks.
          </li>
          <li>
            <strong>Savings Rate (30%)</strong> - Tracks what percentage of your allowance you save versus spend. 
            Higher savings rates show financial responsibility and planning ahead.
          </li>
          <li>
            <strong>Merchant Diversity (25%)</strong> - Rewards shopping at a variety of approved merchants across 
            different categories. This shows responsible exploration and spending diversity.
          </li>
          <li>
            <strong>Financial Education (10%)</strong> - Based on your engagement with learning modules and financial 
            literacy content. Completing lessons and earning XP demonstrates commitment to financial education.
          </li>
        </ul>
        <p className="explanation-note">
          Each factor is scored out of 100, then multiplied by its weight percentage to contribute to your total score.
        </p>
      </div>

      <div className="breakdown-grid">
        {categories.map((category) => {
          const percentage = (category.score / category.maxScore) * 100
          const contribution = (category.score * category.weight) / 100
          
          return (
            <div key={category.key} className="breakdown-card">
              <div className="breakdown-card-header">
                <span className="breakdown-icon">{getCategoryIcon(category.key)}</span>
                <div className="breakdown-title-group">
                  <h3>{getCategoryName(category.key)}</h3>
                  <span className="breakdown-weight">Weight: {category.weight}%</span>
                </div>
              </div>

              <div className="breakdown-score">
                <div className="breakdown-score-value">
                  <span className="score-number">{category.score}</span>
                  <span className="score-max">/{category.maxScore}</span>
                </div>
                <div className="breakdown-progress">
                  <div className="progress-bar">
                    <div 
                      className="progress-fill" 
                      style={{ width: `${percentage}%` }}
                    ></div>
                  </div>
                </div>
              </div>

              <p className="breakdown-description">{category.description}</p>

              {parentMode && (
                <div className="breakdown-details">
                  <h4>Details:</h4>
                  <ul className="details-list">
                    {category.details.map((detail, index) => (
                      <li key={index} className={`detail-item ${detail.impact}`}>
                        <span className="detail-factor">{detail.factor}:</span>
                        <span className="detail-value">{detail.value}</span>
                      </li>
                    ))}
                  </ul>
                  <div className="breakdown-contribution">
                    Contribution to score: <strong>{contribution.toFixed(1)} points</strong>
                  </div>
                </div>
              )}
            </div>
          )
        })}
      </div>

      {parentMode && (
        <div className="breakdown-insights">
          <h3>💡 Parent Insights</h3>
          <p>In parent mode, you can see detailed breakdowns of how each factor affects the credit score. 
             This helps you guide your teen toward behaviors that positively impact their credit.</p>
        </div>
      )}
    </div>
  )
}

export default BreakdownSection

