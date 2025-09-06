import SwiftUI

struct LearnView: View {
    @EnvironmentObject var algorandService: AlgorandService
    @State private var selectedModule: LearningModule?
    @State private var userXP = 325
    @State private var currentLevel = 3
    @State private var completedModules: Set<String> = ["budgeting_basics", "smart_spending"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    creditBuildingHeader
                    
                    allowanceProgressSection
                    
                    financialEducationModules
                    
                    fraudPreventionEducation
                    
                    achievementSection
                    
                    blockchainBasics
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Learn & Earn")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedModule) { module in
                LearningModuleDetailView(module: module, userXP: $userXP, completedModules: $completedModules)
            }
            .background(Color.white)
        }
    }
    
    private var creditBuildingHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learn Smart Spending")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Good financial decisions = Higher credit limits & allowances")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("23")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Smart Purchases")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("179.97 ALGO")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Fraud Avoided")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("742")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Credit Score")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var allowanceProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Earn Higher Allowances")
                    .font(.headline)
                
                Spacer()
                
                Text("Level 3")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .purple.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to +25 ALGO Weekly Increase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(userXP)/500 XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(userXP), total: 500)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Complete learning modules to unlock higher spending limits!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private var financialEducationModules: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Education Modules")
                .font(.headline)
            
            Text("Complete these to earn higher credit limits and allowance increases!")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(LearningModule.creditFocusedModules, id: \.id) { module in
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
    
    private var fraudPreventionEducation: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learn Smart Money Habits")
                .font(.headline)
            
            InfoCard(
                title: "Smart Spending Decisions",
                description: "Learn to identify good vs bad purchases. Smart decisions increase your credit score and unlock higher allowances.",
                icon: "brain.head.profile",
                color: .green
            )
            
            InfoCard(
                title: "Fraud Prevention = More Trust",
                description: "When you avoid fraudulent merchants, parents see you're responsible and increase your spending limits.",
                icon: "checkmark.shield.fill",
                color: .blue
            )
            
            InfoCard(
                title: "Budget Tracking Rewards",
                description: "Stay under your daily limits and complete educational modules to earn allowance bonuses and credit increases.",
                icon: "target",
                color: .orange
            )
        }
    }
    
    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Credit Building Milestones")
                .font(.headline)
            
            VStack(spacing: 12) {
                AchievementRow(
                    title: "Smart Budgeter (+10 ALGO/week)",
                    description: "Completed budgeting module - earned allowance increase",
                    icon: "chart.pie.fill",
                    isUnlocked: true
                )
                
                AchievementRow(
                    title: "Fraud Fighter (+15 ALGO credit)",
                    description: "Avoided scams - unlocked higher credit limits",
                    icon: "shield.fill",
                    isUnlocked: true
                )
                
                AchievementRow(
                    title: "Savings Master (2x multiplier)",
                    description: "Hit savings goals - earned double allowances",
                    icon: "target",
                    isUnlocked: false
                )
                
                AchievementRow(
                    title: "Credit Score NFT (Adult Access)",
                    description: "Built permanent financial reputation",
                    icon: "star.fill",
                    isUnlocked: true
                )
            }
        }
    }
    
    private var blockchainBasics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Financial Future on Blockchain")
                .font(.headline)
            
            VStack(spacing: 12) {
                InfoCard(
                    title: "Permanent Credit History",
                    description: "Your responsible purchases create an immutable record on Algorand - banks can verify your creditworthiness instantly.",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                InfoCard(
                    title: "Portable Reputation",
                    description: "Your Credit Score NFT travels with you to any bank or financial institution - no more starting from zero.",
                    icon: "arrow.triangle.2.circlepath",
                    color: .green
                )
                
                InfoCard(
                    title: "Revolutionary Protection",
                    description: "Be part of the first generation to have fraud prevented BEFORE payment, not detected after - this is the future of finance.",
                    icon: "sparkles",
                    color: .purple
                )
            }
            
            Button(action: {
                if let url = URL(string: "https://testnet.algoexplorer.io/asset/745477123") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Text("View Your Credit Score NFT")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.up.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(12)
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
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 1)
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
    
    static let creditFocusedModules = [
        LearningModule(
            id: "budgeting_basics",
            title: "Smart Budgeting = Higher Allowances",
            description: "Learn budgeting to unlock +10 ALGO weekly increases",
            icon: "chart.pie.fill",
            xpReward: 50,
            requiredLevel: 1,
            content: [
                "Smart budgeting shows parents you're responsible with money - leading to higher allowances and credit limits!",
                "The 50/30/20 rule: 50% for needs, 30% for wants, 20% for savings. Following this can unlock bonus allowances.",
                "Track your spending to show parents exactly where your money goes - transparency builds trust.",
                "Congratulations! You've mastered budgeting basics. Your responsible planning has earned you +10 ALGO weekly allowance increase!"
            ]
        ),
        
        LearningModule(
            id: "smart_spending",
            title: "Fraud Avoidance = Credit Boost",
            description: "Learn to spot scams and earn +15 ALGO credit increases",
            icon: "shield.fill",
            xpReward: 75,
            requiredLevel: 2,
            content: [
                "Avoiding fraudulent merchants shows excellent judgment - parents reward this with higher credit limits!",
                "Red flags: Deals that seem too good to be true, unfamiliar websites, urgent purchase pressure.",
                "Always verify merchant legitimacy before purchasing. ClearSpend's attestation network helps protect you.",
                "Smart fraud avoidance has unlocked +15 ALGO credit limit increase and shows you're ready for more financial responsibility!"
            ]
        ),
        
        LearningModule(
            id: "saving_strategies",
            title: "Saving Goals = Allowance Multipliers",
            description: "Hit savings targets to unlock 2x weekly allowances",
            icon: "target",
            xpReward: 100,
            requiredLevel: 3,
            content: [
                "Parents love seeing teens save money! Reaching savings goals can unlock 2x weekly allowance multipliers.",
                "Start with small goals: Save 25 ALGO this month to unlock bonus allowances next month.",
                "Set specific targets: Phone upgrade fund, college savings, emergency buffer - each goal shows maturity.",
                "Automate savings to show consistency. Parents reward reliability with increased financial freedom.",
                "Congratulations! Your smart saving habits have earned you 2x allowance multipliers and shown true financial maturity!"
            ]
        ),
        
        LearningModule(
            id: "blockchain_credit",
            title: "Blockchain Credit = Adult Financial Access",
            description: "Understand how blockchain builds your financial future",
            icon: "link.circle.fill",
            xpReward: 125,
            requiredLevel: 4,
            content: [
                "Your blockchain credit history follows you to any bank or financial institution - no more starting from zero!",
                "Every smart purchase decision is permanently recorded, creating unbreakable proof of your financial responsibility.",
                "Traditional credit cards require income verification. Your ClearSpend history can bypass these requirements.",
                "Your Credit Score NFT is portable proof of responsible spending - banks will compete for customers like you!",
                "Amazing! You now understand how blockchain technology will give you a massive advantage in adult financial life."
            ]
        )
    ]
}

#Preview {
    LearnView()
        .environmentObject(AlgorandService())
}