import Foundation

struct CreditBreakdown {
    let currentScore: Int
    let scoreRange: ScoreRange
    let scoreLevel: String
    let scoreColor: String
    let breakdown: [CreditFactor]
    let milestones: [Milestone]
    let recentActivity: [ScoreActivity]
    
    struct ScoreRange {
        let min: Int
        let max: Int
    }
    
    struct CreditFactor: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let score: Int
        let maxScore: Int
        let weight: Int
        let description: String
        let details: [FactorDetail]
        
        var percentage: Double {
            Double(score) / Double(maxScore) * 100
        }
        
        var contribution: Double {
            Double(score) * Double(weight) / 100.0
        }
    }
    
    struct FactorDetail: Identifiable {
        let id = UUID()
        let factor: String
        let value: String
        let impact: ImpactType
        
        enum ImpactType {
            case positive
            case negative
            case neutral
        }
    }
    
    struct Milestone: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let icon: String
        let achieved: Bool
        let achievedDate: Date?
        let progress: Int?
        let target: Int?
        let points: Int
        
        var progressPercentage: Double {
            guard let progress = progress, let target = target, target > 0 else { return 0 }
            return min(100, Double(progress) / Double(target) * 100)
        }
    }
    
    struct ScoreActivity: Identifiable {
        let id = UUID()
        let date: Date
        let action: String
        let change: String
        let reason: String
    }
}

// MARK: - Mock Data
extension CreditBreakdown {
    static let mock = CreditBreakdown(
        currentScore: 742,
        scoreRange: ScoreRange(min: 300, max: 850),
        scoreLevel: "Excellent",
        scoreColor: "green",
        breakdown: [
            CreditFactor(
                name: "Spending Consistency",
                icon: "chart.bar.fill",
                score: 85,
                maxScore: 100,
                weight: 35,
                description: "Consistency in spending patterns and responsible purchase behavior",
                details: [
                    FactorDetail(factor: "Regular purchases", value: "23 verified purchases", impact: .positive),
                    FactorDetail(factor: "Spending streak", value: "3 weeks consistent", impact: .positive),
                    FactorDetail(factor: "No overspending", value: "0 instances", impact: .positive)
                ]
            ),
            CreditFactor(
                name: "Savings Rate",
                icon: "banknote.fill",
                score: 72,
                maxScore: 100,
                weight: 30,
                description: "Percentage of allowance saved versus spent",
                details: [
                    FactorDetail(factor: "Monthly savings", value: "28% of allowance", impact: .positive),
                    FactorDetail(factor: "Round-up savings", value: "1 completed", impact: .positive),
                    FactorDetail(factor: "Emergency fund", value: "$45 saved", impact: .positive)
                ]
            ),
            CreditFactor(
                name: "Merchant Diversity",
                icon: "building.2.fill",
                score: 78,
                maxScore: 100,
                weight: 25,
                description: "Variety of merchants and responsible category spending",
                details: [
                    FactorDetail(factor: "Merchants used", value: "12 different merchants", impact: .positive),
                    FactorDetail(factor: "Category diversity", value: "5 categories", impact: .positive),
                    FactorDetail(factor: "High-reputation merchants", value: "85% of purchases", impact: .positive)
                ]
            ),
            CreditFactor(
                name: "Financial Education",
                icon: "book.fill",
                score: 90,
                maxScore: 100,
                weight: 10,
                description: "Engagement with financial literacy modules",
                details: [
                    FactorDetail(factor: "Modules completed", value: "4 of 5 modules", impact: .positive),
                    FactorDetail(factor: "XP earned", value: "350 XP", impact: .positive),
                    FactorDetail(factor: "Learning streak", value: "7 days", impact: .positive)
                ]
            )
        ],
        milestones: [
            Milestone(
                title: "First Round-Up Savings",
                description: "Completed your first round-up savings transaction",
                icon: "💾",
                achieved: true,
                achievedDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
                progress: nil,
                target: nil,
                points: 25
            ),
            Milestone(
                title: "3 Weeks of Responsible Spending",
                description: "Maintained consistent spending for 3 consecutive weeks",
                icon: "🔥",
                achieved: true,
                achievedDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
                progress: nil,
                target: nil,
                points: 50
            ),
            Milestone(
                title: "Diverse Shopping",
                description: "Made purchases from 5 different merchants",
                icon: "🏪",
                achieved: true,
                achievedDate: Calendar.current.date(byAdding: .day, value: -12, to: Date()),
                progress: nil,
                target: nil,
                points: 30
            ),
            Milestone(
                title: "Credit Elite",
                description: "Reach a credit score of 750+",
                icon: "🏆",
                achieved: false,
                achievedDate: nil,
                progress: 742,
                target: 750,
                points: 100
            ),
            Milestone(
                title: "Monthly Champion",
                description: "4 weeks of consistent responsible spending",
                icon: "⭐",
                achieved: false,
                achievedDate: nil,
                progress: 3,
                target: 4,
                points: 75
            ),
            Milestone(
                title: "Century Saver",
                description: "Save $100 in your emergency fund",
                icon: "💰",
                achieved: false,
                achievedDate: nil,
                progress: 45,
                target: 100,
                points: 75
            )
        ],
        recentActivity: [
            ScoreActivity(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                action: "Credit score increased",
                change: "+5 points",
                reason: "Completed 3 weeks of responsible spending milestone"
            ),
            ScoreActivity(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                action: "Milestone achieved",
                change: "+50 points",
                reason: "3 Weeks of Responsible Spending"
            ),
            ScoreActivity(
                date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                action: "Credit score increased",
                change: "+3 points",
                reason: "Increased savings rate to 28%"
            ),
            ScoreActivity(
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                action: "Milestone achieved",
                change: "+25 points",
                reason: "First Round-Up Savings completed"
            )
        ]
    )
}

