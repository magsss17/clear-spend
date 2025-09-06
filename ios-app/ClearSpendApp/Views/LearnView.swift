import SwiftUI

struct LearnView: View {
    @State private var selectedModule: LearningModule?
    @State private var userXP = 325
    @State private var currentLevel = 3
    @State private var completedModules: Set<String> = ["budgeting_basics", "smart_spending"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    progressHeader
                    
                    learningModules
                    
                    achievementSection
                    
                    blockchainEducation
                }
                .padding()
            }
            .navigationTitle("Learn")
            .sheet(item: $selectedModule) { module in
                LearningModuleDetailView(module: module, userXP: $userXP, completedModules: $completedModules)
            }
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Level \(currentLevel) - Smart Spender")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(userXP) XP earned!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }
            
            // XP Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to Level \(currentLevel + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(userXP)/500 XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(userXP), total: 500)
                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private var learningModules: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Education")
                .font(.headline)
            
            ForEach(LearningModule.allModules, id: \.id) { module in
                ModuleCard(
                    module: module,
                    isCompleted: completedModules.contains(module.id),
                    isLocked: !module.isUnlocked(currentLevel: currentLevel)
                ) {
                    selectedModule = module
                }
            }
        }
    }
    
    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.headline)
            
            VStack(spacing: 12) {
                AchievementRow(
                    title: "Smart Spender",
                    description: "Made 5 approved purchases",
                    icon: "checkmark.circle.fill",
                    isUnlocked: true
                )
                
                AchievementRow(
                    title: "Budget Master",
                    description: "Stayed under daily limit for 7 days",
                    icon: "target",
                    isUnlocked: true
                )
                
                AchievementRow(
                    title: "Crypto Native",
                    description: "Learn about blockchain basics",
                    icon: "link",
                    isUnlocked: false
                )
            }
        }
    }
    
    private var blockchainEducation: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Understanding Your Money")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoCard(
                    title: "Your ClearSpend Dollars",
                    description: "CSD tokens are real digital assets on Algorand blockchain - they're like digital cash that only you control!",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                InfoCard(
                    title: "Every Purchase is Verified",
                    description: "Before your money moves, smart contracts check if the purchase is allowed. This prevents overspending automatically!",
                    icon: "checkmark.shield.fill",
                    color: .blue
                )
                
                InfoCard(
                    title: "Building Credit History",
                    description: "Every responsible purchase builds your on-chain reputation - creating a verifiable credit history for your future!",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
        }
    }
}

struct ModuleCard: View {
    let module: LearningModule
    let isCompleted: Bool
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: module.icon)
                    .font(.title2)
                    .foregroundColor(isLocked ? .gray : .purple)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                    
                    Text(module.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack {
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    } else {
                        Text("+\(module.xpReward)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .disabled(isLocked)
        .buttonStyle(PlainButtonStyle())
    }
}

struct AchievementRow: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Text("Unlocked!")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}

struct InfoCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct LearningModuleDetailView: View {
    let module: LearningModule
    @Binding var userXP: Int
    @Binding var completedModules: Set<String>
    @Environment(\.dismiss) var dismiss
    
    @State private var currentStep = 0
    @State private var isCompleted = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(module.content[currentStep])
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    if currentStep < module.content.count - 1 {
                        Button("Next") {
                            currentStep += 1
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Complete Module (+\(module.xpReward) XP)") {
                            completeModule()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isCompleted)
                    }
                }
                .padding()
            }
            .navigationTitle(module.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func completeModule() {
        userXP += module.xpReward
        completedModules.insert(module.id)
        isCompleted = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
        }
    }
}

// MARK: - Data Models

struct LearningModule: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let requiredLevel: Int
    let content: [String]
    
    func isUnlocked(currentLevel: Int) -> Bool {
        return currentLevel >= requiredLevel
    }
    
    static let allModules = [
        LearningModule(
            id: "budgeting_basics",
            title: "Budgeting Basics",
            description: "Learn how to create and stick to a budget",
            icon: "chart.pie.fill",
            xpReward: 50,
            requiredLevel: 1,
            content: [
                "A budget is your spending plan - it helps you decide where your money goes before you spend it.",
                "The 50/30/20 rule: 50% for needs, 30% for wants, 20% for savings.",
                "Track your spending for a week to see where your money really goes.",
                "Great job! You've learned the basics of budgeting. Remember: every dollar should have a purpose!"
            ]
        ),
        
        LearningModule(
            id: "smart_spending",
            title: "Smart Spending",
            description: "Make better purchase decisions",
            icon: "brain.head.profile",
            xpReward: 75,
            requiredLevel: 2,
            content: [
                "Before buying anything, ask yourself: Do I need this or just want it?",
                "Use the 24-hour rule: Wait a day before making non-essential purchases.",
                "Compare prices across different stores and websites.",
                "Consider the cost per use - expensive items can be worth it if you use them often.",
                "Excellent! You're now a smart spender who makes thoughtful purchase decisions."
            ]
        ),
        
        LearningModule(
            id: "saving_strategies",
            title: "Saving Strategies",
            description: "Build wealth with smart saving habits",
            icon: "banknote.fill",
            xpReward: 100,
            requiredLevel: 3,
            content: [
                "Pay yourself first - save money before spending on anything else.",
                "Start small: even $1 per day adds up to $365 per year!",
                "Set specific savings goals: vacation, car, college, emergency fund.",
                "Automate your savings so you don't have to think about it.",
                "Amazing! You now understand how small savings can grow into big opportunities."
            ]
        ),
        
        LearningModule(
            id: "blockchain_money",
            title: "Digital Money & Blockchain",
            description: "Understand how your ClearSpend Dollars work",
            icon: "link.circle.fill",
            xpReward: 125,
            requiredLevel: 4,
            content: [
                "Blockchain is like a digital ledger that records all transactions permanently.",
                "Your ClearSpend Dollars (CSD) are real tokens on the Algorand blockchain.",
                "Smart contracts automatically enforce spending rules set by your parents.",
                "Every purchase creates a permanent record that builds your financial reputation.",
                "Congratulations! You understand the future of money and how blockchain protects your finances."
            ]
        )
    ]
}