import SwiftUI

struct TransactionHistoryView: View {
    @EnvironmentObject var walletViewModel: WalletViewModel
    @State private var selectedFilter = "All"
    @State private var searchText = ""
    
    let filters = ["All", "Approved", "Rejected", "Pending"]
    
    var filteredTransactions: [Transaction] {
        walletViewModel.recentTransactions.filter { transaction in
            let matchesFilter = selectedFilter == "All" || transaction.status.rawValue == selectedFilter
            let matchesSearch = searchText.isEmpty || 
                transaction.merchant.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                filterSection
                
                if filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
            .padding()
        }
        .navigationTitle("Transaction History")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search transactions")
        .task {
            await walletViewModel.loadTransactionHistory()
        }
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(filters, id: \.self) { filter in
                    FilterChip(
                        title: filter,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
        }
    }
    
    private var transactionsList: some View {
        VStack(spacing: 0) {
            ForEach(filteredTransactions) { transaction in
                VStack(spacing: 0) {
                    TransactionRowView(transaction: transaction)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    
                    Divider()
                        .padding(.leading, 52)
                }
                .background(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let link = transaction.explorerLink,
                       let url = URL(string: link) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No transactions found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Try adjusting your filters or search")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionHistoryView()
            .environmentObject(WalletViewModel())
    }
}