import React from 'react'
import './ScoreDisplay.css'

function ScoreDisplay({ score, scoreRange, level, color, recentActivity }) {
  const scorePercentage = ((score - scoreRange.min) / (scoreRange.max - scoreRange.min)) * 100

  return (
    <div className="score-display">
      <div className="score-card">
        <div className="score-header">
          <h2>Current Credit Score</h2>
          <span className="score-badge" style={{ backgroundColor: color + '20', color: color }}>
            {level}
          </span>
        </div>
        
        <div className="score-main">
          <div className="score-number" style={{ color: color }}>
            {score}
          </div>
          <div className="score-range">
            <span>{scoreRange.min}</span>
            <div className="score-progress-bar">
              <div 
                className="score-progress-fill" 
                style={{ 
                  width: `${scorePercentage}%`,
                  backgroundColor: color
                }}
              ></div>
            </div>
            <span>{scoreRange.max}</span>
          </div>
        </div>

        <div className="score-description">
          <p>Built from {recentActivity.length > 0 ? recentActivity[0].reason : 'verified transactions'}</p>
        </div>
      </div>

      {recentActivity && recentActivity.length > 0 && (
        <div className="recent-activity">
          <h3>Recent Activity</h3>
          <ul className="activity-list">
            {recentActivity.slice(0, 3).map((activity, index) => (
              <li key={index} className="activity-item">
                <div className="activity-date">{new Date(activity.date).toLocaleDateString()}</div>
                <div className="activity-content">
                  <span className="activity-action">{activity.action}</span>
                  <span className="activity-change positive">{activity.change}</span>
                </div>
                <div className="activity-reason">{activity.reason}</div>
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  )
}

export default ScoreDisplay

