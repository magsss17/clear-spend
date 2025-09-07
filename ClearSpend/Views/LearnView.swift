import SwiftUI

struct LearnView: View {
    @EnvironmentObject var algorandService: AlgorandService
    @State private var userXP = 325
    @State private var currentLevel = 3
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    creditBuildingHeader
                    
                    allowanceProgressSection
                    
                    financialEducationModules
                    
                    daoEducationSection
                    
                    yieldEducationSection
                    
                    // fraudPreventionEducation
                    
                    // achievementSection
                    
                    // blockchainBasics
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Learn & Earn")
            .navigationBarTitleDisplayMode(.large)
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
                        .foregroundColor(.gray)
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
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("$6.00")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Fraud Avoided")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("742")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Credit Score")
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
                    Text("Progress to +$2 Weekly Increase")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(userXP)/500 XP")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                ProgressView(value: Double(userXP), total: 500)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Complete learning modules to unlock higher spending limits!")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private var financialEducationModules: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Education Resources")
                .font(.headline)
            
            Text("Learn from trusted financial education sources")
                .font(.caption)
                .foregroundColor(.gray)
            
            InfoCard(
                title: "Smart budgeting",
                description: "Learn popular budgeting strategies to manage your money effectively and build long-term wealth.",
                icon: "chart.pie.fill",
                color: .green,
                url: "https://srfs.upenn.edu/financial-wellness/browse-topics/budgeting/popular-budgeting-strategies"
            )
            
            InfoCard(
                title: "Fraud",
                description: "Protect yourself from scams and fraudulent activities. Learn how to identify and avoid common financial traps.",
                icon: "shield.fill",
                color: .red,
                url: "https://consumer.ftc.gov/articles/how-avoid-scam?utm_source=chatgpt.com"
            )
            
            InfoCard(
                title: "Savings",
                description: "Build emergency funds and prepare for unexpected expenses. Learn essential risk management strategies.",
                icon: "banknote.fill",
                color: .blue,
                url: "https://www.federalreserveeducation.org/teaching-resources/personal-finance/managing-risk/when-the-unexpected-happens?utm_source=chatgpt.com"
            )
        }
    }
    
    // MARK: - Fraud Prevention Education
    /*
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
                    title: "Smart Budgeter (+$10/week)",
                    description: "Completed budgeting module - earned allowance increase",
                    icon: "chart.pie.fill",
                    isUnlocked: true
                )
                
                AchievementRow(
                    title: "Fraud Fighter (+$15 credit)",
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
    
    */
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
    
    private var daoEducationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Decentralized Organizations (DAOs)")
                .font(.headline)
            
            Text("Learn about the future of community governance and decision making")
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                InfoCard(
                    title: "DAO",
                    description: "Decentralized Autonomous Organizations let communities make decisions together without traditional management. Members vote on proposals using digital tokens.",
                    icon: "person.3.fill",
                    color: .blue,
                    url: "https://ethereum.org/dao/?utm_source=chatgpt.com"
                )
                
            }
        }
    }
    
    private var yieldEducationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Onchain Yield Opportunities")
                .font(.headline)
            
            Text("Discover how to earn passive income through decentralized finance")
                .font(.caption)
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                InfoCard(
                    title: "Staking rewards",
                    description: "Lock up your digital assets to help secure networks and earn steady rewards. Think of it like earning interest on your savings.",
                    icon: "lock.shield.fill",
                    color: .green,
                    url: "https://ethereum.org/staking/?utm_source=chatgpt.com"
                )
                
                InfoCard(
                    title: "Liquidity provisioning",
                    description: "Provide funds to decentralized exchanges and earn fees from traders. You become part of the financial infrastructure.",
                    icon: "arrow.triangle.2.circlepath",
                    color: .purple,
                    url: "https://docs.uniswap.org/contracts/v2/concepts/advanced-topics/understanding-returns?utm_source=chatgpt.com"
                )
                
            }
        }
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
                    .foregroundColor(.gray)
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
    let url: String?
    
    init(title: String, description: String, icon: String, color: Color, url: String? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.color = color
        self.url = url
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                if let url = url {
                    Button(action: {
                        if let urlObject = URL(string: url) {
                            UIApplication.shared.open(urlObject)
                        }
                    }) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
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


