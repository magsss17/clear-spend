import SwiftUI

struct CreditJourneyView: View {
    @State private var creditData = CreditBreakdown.mock
    @State private var parentMode = false
    
    private var scoreColor: Color {
        switch creditData.scoreColor.lowercased() {
        case "green":
            return .green
        case "blue":
            return .blue
        case "orange":
            return .orange
        case "red":
            return .red
        default:
            return .green
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scoreDisplayCard
                
                breakdownExplanation
                
                breakdownSection
                
                milestonesSection
                
                if parentMode {
                    parentInsightsSection
                }
            }
            .padding()
        }
        .background(Color.white)
        .navigationTitle("Credit Journey")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Text("Parent Mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Toggle("", isOn: $parentMode)
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                }
            }
        }
    }
    
    private var scoreDisplayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Credit Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(creditData.scoreLevel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(scoreColor.opacity(0.15))
                    .cornerRadius(12)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                Text("\(creditData.currentScore)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(creditData.scoreRange.min)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(scoreColor)
                                .frame(
                                    width: geometry.size.width * CGFloat(Double(creditData.currentScore - creditData.scoreRange.min) / Double(creditData.scoreRange.max - creditData.scoreRange.min)),
                                    height: 8
                                )
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(creditData.scoreRange.max)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var breakdownExplanation: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📖")
                    .font(.title2)
                Text("How Your Credit Score is Calculated")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text("Your credit score (out of \(creditData.scoreRange.max)) is calculated by combining four key factors, each with a specific weight:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 8) {
                explanationItem(
                    title: "Spending Consistency (35%)",
                    description: "Measures how consistently you make responsible purchases. Factors include regular spending patterns, no overspending instances, and maintaining good spending streaks."
                )
                
                explanationItem(
                    title: "Savings Rate (30%)",
                    description: "Tracks what percentage of your allowance you save versus spend. Higher savings rates show financial responsibility and planning ahead."
                )
                
                explanationItem(
                    title: "Merchant Diversity (25%)",
                    description: "Rewards shopping at a variety of approved merchants across different categories. This shows responsible exploration and spending diversity."
                )
                
                explanationItem(
                    title: "Financial Education (10%)",
                    description: "Based on your engagement with learning modules and financial literacy content. Completing lessons and earning XP demonstrates commitment to financial education."
                )
            }
            
            Text("Each factor is scored out of 100, then multiplied by its weight percentage to contribute to your total score.")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
                .padding(.top, 4)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func explanationItem(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
    }
    
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Credit Score Breakdown")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your credit score is calculated from these factors:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(creditData.breakdown) { factor in
                breakdownCard(factor: factor)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func breakdownCard(factor: CreditBreakdown.CreditFactor) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: factor.icon)
                    .font(.title2)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(factor.name)
                        .font(.headline)
                    
                    Text("Weight: \(factor.weight)%")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text("\(factor.score)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text("/\(factor.maxScore)")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.purple.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(factor.percentage / 100),
                            height: 8
                        )
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text(factor.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if parentMode {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    Text("Details:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(factor.details) { detail in
                        HStack {
                            Text(detail.factor + ":")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(detail.value)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            detail.impact == .positive ? Color.green.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(6)
                    }
                    
                    HStack {
                        Text("Contribution to score:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(factor.contribution, specifier: "%.1f") points")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones & Badges")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Track your progress and unlock achievements")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            let achieved = creditData.milestones.filter { $0.achieved }
            let pending = creditData.milestones.filter { !$0.achieved }
            
            if !achieved.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("✅ Achieved")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    ForEach(achieved) { milestone in
                        milestoneCard(milestone: milestone, achieved: true)
                    }
                }
            }
            
            if !pending.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("🎯 In Progress")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    ForEach(pending) { milestone in
                        milestoneCard(milestone: milestone, achieved: false)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func milestoneCard(milestone: CreditBreakdown.Milestone, achieved: Bool) -> some View {
        HStack(spacing: 12) {
            Text(milestone.icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.headline)
                
                Text(milestone.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if achieved {
                    if let date = milestone.achievedDate {
                        Text("Achieved: \(date, style: .date)")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                } else {
                    if let progress = milestone.progress, let target = milestone.target {
                        HStack(spacing: 4) {
                            Text("\(progress)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                            
                            Text("/\(target)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                    .cornerRadius(3)
                                
                                Rectangle()
                                    .fill(Color.purple)
                                    .frame(
                                        width: geometry.size.width * CGFloat(milestone.progressPercentage / 100),
                                        height: 6
                                    )
                                    .cornerRadius(3)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            
            Spacer()
            
            if achieved {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            
            VStack(alignment: .trailing) {
                Text("+\(milestone.points)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                Text("pts")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            achieved
                ? LinearGradient(
                    colors: [Color.green.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                : LinearGradient(
                    colors: [Color.gray.opacity(0.05), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    achieved ? Color.green.opacity(0.3) : Color.gray.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
    
    private var parentInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💡")
                    .font(.title2)
                Text("Parent Insights")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("In parent mode, you can see detailed breakdowns of how each factor affects the credit score. This helps you guide your teen toward behaviors that positively impact their credit.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(alignment: .leading, spacing: 12) {
                insightCard(
                    category: "Spending Patterns",
                    insight: "Your teen shows consistent spending across approved categories. No unauthorized purchases detected.",
                    recommendation: "Consider encouraging exploration of educational merchants to boost credit score."
                )
                
                insightCard(
                    category: "Savings Behavior",
                    insight: "Savings rate has improved from 20% to 28% over the past month. Round-up feature is engaging.",
                    recommendation: "Set a savings goal milestone to maintain motivation."
                )
                
                insightCard(
                    category: "Merchant Diversity",
                    insight: "Good diversity with 12 merchants across 5 categories. High-reputation merchant usage is excellent.",
                    recommendation: "Continue exploring new approved merchants to boost diversity score."
                )
                
                insightCard(
                    category: "Financial Education",
                    insight: "Strong engagement with learning modules. 7-day learning streak shows commitment.",
                    recommendation: "Complete remaining modules to unlock full credit score potential."
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.15), Color.yellow.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func insightCard(category: String, insight: String, recommendation: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(insight)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 4) {
                Text("Recommendation:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(recommendation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        CreditJourneyView()
    }
}

