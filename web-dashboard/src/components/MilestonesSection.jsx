import React from 'react'
import './MilestonesSection.css'

function MilestonesSection({ milestones }) {
  const achievedMilestones = milestones.filter(m => m.achieved)
  const pendingMilestones = milestones.filter(m => !m.achieved)

  return (
    <div className="milestones-section">
      <h2>Milestones & Badges</h2>
      <p className="milestones-subtitle">
        Track your progress and unlock achievements
      </p>

      {achievedMilestones.length > 0 && (
        <div className="milestones-group">
          <h3 className="milestones-group-title">
            <span className="badge-icon">✅</span> Achieved
          </h3>
          <div className="milestones-grid">
            {achievedMilestones.map((milestone) => (
              <div key={milestone.id} className="milestone-card achieved">
                <div className="milestone-icon">{milestone.icon}</div>
                <div className="milestone-content">
                  <h4>{milestone.title}</h4>
                  <p>{milestone.description}</p>
                  <div className="milestone-meta">
                    <span className="milestone-date">
                      Achieved: {new Date(milestone.achievedDate).toLocaleDateString()}
                    </span>
                    <span className="milestone-points">+{milestone.points} pts</span>
                  </div>
                </div>
                <div className="milestone-badge achieved-badge">✓</div>
              </div>
            ))}
          </div>
        </div>
      )}

      {pendingMilestones.length > 0 && (
        <div className="milestones-group">
          <h3 className="milestones-group-title">
            <span className="badge-icon">🎯</span> In Progress
          </h3>
          <div className="milestones-grid">
            {pendingMilestones.map((milestone) => {
              const progress = milestone.progress || 0
              const target = milestone.target || 1
              const progressPercentage = Math.min((progress / target) * 100, 100)
              
              return (
                <div key={milestone.id} className="milestone-card pending">
                  <div className="milestone-icon">{milestone.icon}</div>
                  <div className="milestone-content">
                    <h4>{milestone.title}</h4>
                    <p>{milestone.description}</p>
                    <div className="milestone-progress">
                      <div className="progress-info">
                        <span>{progress}</span>
                        <span>/</span>
                        <span>{target}</span>
                      </div>
                      <div className="progress-bar">
                        <div 
                          className="progress-fill" 
                          style={{ width: `${progressPercentage}%` }}
                        ></div>
                      </div>
                    </div>
                    <div className="milestone-meta">
                      <span className="milestone-points">+{milestone.points} pts when achieved</span>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        </div>
      )}
    </div>
  )
}

export default MilestonesSection

