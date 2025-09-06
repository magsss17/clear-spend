import Foundation
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var balance: Double = 150.0
    @Published var weeklyAllowance: Double = 50.0
    @Published var recentTransactions: [Transaction] = []
    @Published var savingsBalance: Double = 25.0
    @Published var lockedBalance: Double = 100.0
    @Published var isLoading = false
    
    var formattedBalance: String {
        String(format: "%.2f", balance)
    }
    
    var formattedSavings: String {
        String(format: "%.2f", savingsBalance)
    }
    
    var formattedLocked: String {
        String(format: "%.2f", lockedBalance)
    }
    
    init() {
        loadMockData()
    }
    
    func refreshBalance() async {
        isLoading = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // In production, this would fetch from Algorand blockchain
        // For demo, we're using mock data
        
        isLoading = false
    }
    
    func loadTransactionHistory() async {
        isLoading = true
        
        // Simulate fetching transaction history
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        recentTransactions = [
            Transaction(
                id: UUID().uuidString,
                merchant: "Spotify",
                category: "Entertainment",
                amount: 9.99,
                date: Date().addingTimeInterval(-3600),
                status: .approved,
                transactionHash: "DEMO" + UUID().uuidString.prefix(10),
                note: "Monthly subscription"
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "Amazon",
                category: "Shopping", 
                amount: 24.99,
                date: Date().addingTimeInterval(-7200),
                status: .approved,
                transactionHash: "DEMO" + UUID().uuidString.prefix(10),
                note: "School supplies"
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "Steam",
                category: "Gaming",
                amount: 59.99,
                date: Date().addingTimeInterval(-10800),
                status: .rejected,
                transactionHash: nil,
                note: "Category restricted by parent"
            )
        ]
        
        isLoading = false
    }
    
    private func loadMockData() {
        Task {
            await loadTransactionHistory()
        }
    }
    
    func processSpend(amount: Double, merchant: String, category: String) async -> Bool {
        guard amount <= balance else { return false }
        
        // Check parent-set rules
        if isRestrictedCategory(category) {
            return false
        }
        
        if amount > getDailyLimit() {
            return false
        }
        
        // Process the transaction
        balance -= amount
        
        let newTransaction = Transaction(
            id: UUID().uuidString,
            merchant: merchant,
            category: category,
            amount: amount,
            date: Date(),
            status: .approved,
            transactionHash: "DEMO" + UUID().uuidString.prefix(10),
            note: nil
        )
        
        recentTransactions.insert(newTransaction, at: 0)
        
        return true
    }
    
    private func isRestrictedCategory(_ category: String) -> Bool {
        let restricted = ["Gaming", "Gambling", "Adult Content"]
        return restricted.contains(category)
    }
    
    private func getDailyLimit() -> Double {
        return 50.0 // $50 daily limit for demo
    }
    
    func lockFunds(amount: Double, days: Int) async -> Bool {
        guard amount <= balance else { return false }
        
        balance -= amount
        lockedBalance += amount
        
        // In production, this would create a timelock smart contract
        // For demo, we're just updating the UI
        
        return true
    }
}