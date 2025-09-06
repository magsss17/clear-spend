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
                    
                    recentTransactionsSection
                    
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("ClearSpend")
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
        }
        .task {
            await walletViewModel.refreshBalance()
        }
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Allowance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 8) {
                Text("\(walletViewModel.formattedBalance)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                
                Text("ALGO")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 6)
            }
            
            HStack {
                Label("Weekly Allowance", systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("+50 ALGO")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
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
                            .foregroundColor(.secondary)
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
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var quickActionsSection: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                title: "Request",
                icon: "arrow.down.circle.fill",
                color: .green
            ) {
                // Request allowance action
            }
            
            QuickActionButton(
                title: "Save",
                icon: "lock.fill",
                color: .blue
            ) {
                // Save with timelock action
            }
            
            QuickActionButton(
                title: "Goals",
                icon: "target",
                color: .orange
            ) {
                // View savings goals
            }
        }
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
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}