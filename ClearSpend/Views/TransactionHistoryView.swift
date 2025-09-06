import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var walletViewModel: WalletViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if walletViewModel.recentTransactions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No transactions found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(walletViewModel.recentTransactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .padding(.horizontal)
                            .onTapGesture {
                                if let link = transaction.explorerLink,
                                   let url = URL(string: link) {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await walletViewModel.loadTransactionHistory()
        }
    }
}