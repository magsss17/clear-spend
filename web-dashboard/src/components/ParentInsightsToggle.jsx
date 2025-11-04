import React from 'react'
import './ParentInsightsToggle.css'

function ParentInsightsToggle({ parentMode, onToggle, insights }) {
  return (
    <div className="parent-insights-toggle">
      <div className="toggle-header">
        <h3>Parent Mode</h3>
        <label className="toggle-switch">
          <input 
            type="checkbox" 
            checked={parentMode}
            onChange={(e) => onToggle(e.target.checked)}
          />
          <span className="toggle-slider"></span>
        </label>
      </div>

      <p className="toggle-description">
        {parentMode 
          ? "View detailed insights about credit score factors and behaviors."
          : "Enable parent mode to see detailed credit insights and recommendations."
        }
      </p>

      {parentMode && insights && insights.insights && (
        <div className="parent-insights-content">
          <h4>Credit Insights</h4>
          <div className="insights-list">
            {insights.insights.map((insight, index) => (
              <div key={index} className="insight-item">
                <div className="insight-category">{insight.category}</div>
                <p className="insight-text">{insight.insight}</p>
                <p className="insight-recommendation">
                  <strong>Recommendation:</strong> {insight.recommendation}
                </p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}

export default ParentInsightsToggle

