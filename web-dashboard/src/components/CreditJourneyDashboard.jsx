import React, { useState, useEffect } from 'react'
import ScoreDisplay from './ScoreDisplay'
import BreakdownSection from './BreakdownSection'
import MilestonesSection from './MilestonesSection'
import ParentInsightsToggle from './ParentInsightsToggle'
import './CreditJourneyDashboard.css'

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api/v1'
const DEFAULT_TEEN_ADDRESS =
  import.meta.env.VITE_TEEN_ADDRESS ||
  'DEMO_TEEN_ADDRESS'

const STATIC_FINANCIAL_EDUCATION = {
  score: 90,
  maxScore: 100,
  weight: 10,
  description: 'Engagement with financial literacy modules',
  details: [
    { factor: 'Modules completed', value: '4 of 5 modules', impact: 'positive' },
    { factor: 'XP earned', value: '350 XP', impact: 'positive' },
    { factor: 'Learning streak', value: '7 days', impact: 'positive' }
  ]
}

const SCORE_RANGE = { min: 300, max: 850 }

function toScoreLevel(score) {
  if (score >= 750) return { label: 'Excellent', color: '#10b981' }
  if (score >= 700) return { label: 'Good', color: '#22c55e' }
  if (score >= 650) return { label: 'Fair', color: '#eab308' }
  return { label: 'Building', color: '#f97316' }
}

function fetchJson(path) {
  return fetch(`${API_BASE_URL}${path}`).then(async (response) => {
    if (!response.ok) {
      const text = await response.text()
      throw new Error(`Request failed (${response.status}): ${text}`)
    }
    return response.json()
  })
}

function isLikelyAlgorandAddress(value) {
  return /^[A-Z2-7]{58}$/.test(value || '')
}

function toMilestones(milestonesPayload) {
  const raw = milestonesPayload?.data?.milestones
  if (!Array.isArray(raw)) return []
  return raw.map((m, index) => ({
    id: m.milestone_id || `milestone_${index}`,
    title: m.milestone_id || 'Milestone',
    description: m.milestone_id ? `Progress for ${m.milestone_id}` : 'Milestone progress',
    icon: m.achieved ? '🏆' : '🎯',
    achieved: Boolean(m.achieved),
    achievedDate: m.achieved_date ? new Date(m.achieved_date * 1000).toISOString().split('T')[0] : undefined,
    progress: m.progress || 0,
    target: m.target || 100,
    points: m.xp_awarded || 0
  }))
}

function toRecentActivity(transactionsPayload) {
  const txs = transactionsPayload?.transactions || []
  return txs.slice(0, 5).map((tx) => ({
    date: tx.timestamp ? new Date(tx.timestamp * 1000).toISOString() : new Date().toISOString(),
    action: tx.type === 'pay' ? 'Purchase activity' : 'Account activity',
    change: tx.amount ? `${Number(tx.amount).toLocaleString()} microALGO` : '0',
    reason: tx.note || tx.id || 'On-chain activity'
  }))
}

function toParentInsights(parentInsightsPayload) {
  const data = parentInsightsPayload?.data || {}
  const insights = [
    {
      category: 'Spending Patterns',
      insight: `Total outgoing spend: ${Number(data.total_spent || 0).toLocaleString()} microALGO across ${data.spending_transaction_count || 0} transactions.`,
      recommendation: 'Review unusual spikes and reinforce approved merchant spending habits.'
    },
    {
      category: 'Savings Behavior',
      insight: `Savings rate proxy: ${((data.savings_rate || 0) * 100).toFixed(1)}%. Net flow: ${Number(data.net_flow || 0).toLocaleString()} microALGO.`,
      recommendation: 'Encourage consistent savings lock behavior to improve savings-related score factors.'
    },
    {
      category: 'Merchant Diversity',
      insight: `Used ${data.merchant_diversity_count || 0} unique merchants in the current window.`,
      recommendation: 'Balanced merchant/category diversity can improve responsible spending profile.'
    }
  ]

  return { enabled: false, insights }
}

function buildBreakdown(parentInsightsData) {
  const spendCount = Number(parentInsightsData?.spending_transaction_count || 0)
  const merchantDiversityCount = Number(parentInsightsData?.merchant_diversity_count || 0)
  const savingsRatePct = Math.round(Number(parentInsightsData?.savings_rate || 0) * 100)

  const spendingConsistency = Math.min(100, 50 + spendCount * 2)
  const savingsRate = Math.min(100, Math.max(0, savingsRatePct))
  const merchantDiversity = Math.min(100, 40 + merchantDiversityCount * 6)

  return {
    spendingConsistency: {
      score: spendingConsistency,
      maxScore: 100,
      weight: 35,
      description: 'Consistency in spending patterns and responsible purchase behavior',
      details: [
        { factor: 'Outgoing transactions', value: `${spendCount}`, impact: 'positive' },
        { factor: 'Net flow', value: `${Number(parentInsightsData?.net_flow || 0).toLocaleString()} microALGO`, impact: 'positive' }
      ]
    },
    savingsRate: {
      score: savingsRate,
      maxScore: 100,
      weight: 30,
      description: 'Percentage of funds retained relative to outgoing spend',
      details: [
        { factor: 'Savings rate proxy', value: `${savingsRate}%`, impact: savingsRate >= 50 ? 'positive' : 'neutral' },
        { factor: 'Incoming transactions', value: `${Number(parentInsightsData?.incoming_transaction_count || 0)}`, impact: 'positive' }
      ]
    },
    merchantDiversity: {
      score: merchantDiversity,
      maxScore: 100,
      weight: 25,
      description: 'Variety of merchants and responsible category spending',
      details: [
        { factor: 'Unique merchants', value: `${merchantDiversityCount}`, impact: 'positive' },
        { factor: 'Tracked categories', value: `${Object.keys(parentInsightsData?.category_spending || {}).length}`, impact: 'positive' }
      ]
    },
    financialEducation: STATIC_FINANCIAL_EDUCATION
  }
}

function weightedBreakdownScore(breakdown) {
  return (
    breakdown.spendingConsistency.score * 0.35 +
    breakdown.savingsRate.score * 0.3 +
    breakdown.merchantDiversity.score * 0.25 +
    breakdown.financialEducation.score * 0.1
  )
}

function normalizeDashboardData(creditJourneyPayload, transactionsPayload, milestonesPayload, parentInsightsPayload) {
  const profile = creditJourneyPayload?.data || {}
  const parentInsightsData = parentInsightsPayload?.data || {}
  const breakdown = buildBreakdown(parentInsightsData)
  const weightedScore = weightedBreakdownScore(breakdown)
  const fallbackScore = Math.round(SCORE_RANGE.min + (weightedScore / 100) * (SCORE_RANGE.max - SCORE_RANGE.min))
  const score = Number(profile.credit_score || fallbackScore)
  const scoreMeta = toScoreLevel(score)

  return {
    currentScore: score,
    scoreRange: SCORE_RANGE,
    scoreLevel: scoreMeta.label,
    scoreColor: scoreMeta.color,
    breakdown,
    milestones: toMilestones(milestonesPayload),
    recentActivity: toRecentActivity(transactionsPayload),
    parentInsights: toParentInsights(parentInsightsPayload)
  }
}

function CreditJourneyDashboard() {
  const [creditData, setCreditData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [parentMode, setParentMode] = useState(false)
  const [error, setError] = useState(null)

  useEffect(() => {
    let isActive = true

    const loadDashboardData = async () => {
      try {
        const hasValidTeenAddress = isLikelyAlgorandAddress(DEFAULT_TEEN_ADDRESS)
        const requests = [
          fetchJson(`/credit-journey/${DEFAULT_TEEN_ADDRESS}`),
          hasValidTeenAddress
            ? fetchJson(`/transactions/${DEFAULT_TEEN_ADDRESS}`)
            : Promise.resolve({ transactions: [] }),
          fetchJson(`/credit-journey/${DEFAULT_TEEN_ADDRESS}/milestones`),
          hasValidTeenAddress
            ? fetchJson(`/credit-journey/${DEFAULT_TEEN_ADDRESS}/parent-insights`)
            : Promise.resolve({ data: { total_spent: 0, net_flow: 0, savings_rate: 0 } })
        ]

        const settled = await Promise.allSettled(requests)
        const [creditJourneyResult, transactionsResult, milestonesResult, parentInsightsResult] = settled

        const creditJourney = creditJourneyResult.status === 'fulfilled' ? creditJourneyResult.value : { data: {} }
        const transactions = transactionsResult.status === 'fulfilled' ? transactionsResult.value : { transactions: [] }
        const milestones = milestonesResult.status === 'fulfilled' ? milestonesResult.value : { data: { milestones: [] } }
        const parentInsights = parentInsightsResult.status === 'fulfilled'
          ? parentInsightsResult.value
          : { data: { total_spent: 0, net_flow: 0, savings_rate: 0, merchant_diversity_count: 0, category_spending: {} } }

        if (!isActive) return
        setCreditData(
          normalizeDashboardData(creditJourney, transactions, milestones, parentInsights)
        )
      } catch (err) {
        console.error('Error loading credit journey dashboard data:', err)
        if (!isActive) return
        setError('Unable to load live credit journey data.')
      } finally {
        if (isActive) setLoading(false)
      }
    }

    loadDashboardData()
    return () => {
      isActive = false
    }
  }, [])

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="loading-spinner"></div>
        <p>Loading your credit journey...</p>
      </div>
    )
  }

  if (error || !creditData) {
    return (
      <div className="dashboard-error">
        <p>{error || 'Unable to load credit data. Please try again later.'}</p>
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



