import SwiftUI

struct HomeView: View {
    @EnvironmentObject var walletViewModel: WalletViewModel
    @EnvironmentObject var algorandService: AlgorandService
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    balanceCard
                    
                    creditScoreSection
                    
                    // spendingIntegritySection
                    
                    // fraudPreventionSection
                    
                    recentTransactionsSection
                    
                    //quickActionsSection
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("ClearSpend")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .background(Color.white)
        }
        .task {
            await walletViewModel.refreshBalance()
        }
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Available to Spend")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Fraud Protection Active")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                if algorandService.isLoadingBalance {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                } else {
                    Text("\(walletViewModel.formattedBalanceWithDollar)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: TransactionHistoryView()) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            if walletViewModel.recentTransactions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No recent transactions")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ForEach(walletViewModel.recentTransactions) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    

    
    private var creditScoreSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Credit Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Button disabled - View NFT functionality removed
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("742")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("Excellent Credit")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Text("Built from 23 verified $2 purchases")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                /*
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "shield.checkered.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    
                    Text("Blockchain\nVerified")
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                }
                */
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Next milestone")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("750+ score")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                ProgressView(value: 742, total: 750)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var spendingIntegritySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Spending Integrity Score")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View Details")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(walletViewModel.formattedIntegrityScore)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(walletViewModel.integrityScoreColor))
                    
                    Text(walletViewModel.integrityScoreLevel + " Spending")
                        .font(.subheadline)
                        .foregroundColor(Color(walletViewModel.integrityScoreColor))
                    
                    Text("Based on \(walletViewModel.totalVerifiedPurchases) verified purchases")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(walletViewModel.integrityScoreColor))
                    
                    Text("Provably\nGood")
                        .font(.caption)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .frame(width: 25)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Good Spending Streak")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(walletViewModel.goodSpendingStreak) consecutive verified purchases")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(walletViewModel.goodSpendingStreak)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.blue)
                        .frame(width: 25)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Credit Score Boost")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Good spending increases credit score faster")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("+15%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Integrity Factors")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        integrityFactorChip("Education", score: "+50%", color: .blue)
                        integrityFactorChip("Charity", score: "+80%", color: .green)
                        integrityFactorChip("High Rep", score: "+30%", color: .purple)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(walletViewModel.integrityScoreColor).opacity(0.05), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func integrityFactorChip(_ title: String, score: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(score)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var fraudPreventionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Fraud Prevention")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {}) {
                    Text("View Details")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pre-Purchase Verification")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Every transaction verified before payment")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("3 Fraudulent Purchases Blocked")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Saved $127 in potential fraud losses")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("$127")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.purple)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("156 Merchants Verified")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Safe for teen spending")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("156")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}
