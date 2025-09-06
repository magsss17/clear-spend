import Foundation
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var asaBalance: Double = 150.0 // ALGO balance
    @Published var algoBalance: Double = 0.0 // ALGO balance for network fees
    @Published var weeklyAllowance: Double = 50.0
    @Published var recentTransactions: [Transaction] = []
    @Published var savingsBalance: Double = 25.0
    @Published var lockedBalance: Double = 100.0
    @Published var isLoading = false
    @Published var spendingIntegrityScore: Double = 8.7
    @Published var totalVerifiedPurchases: Int = 23
    @Published var goodSpendingStreak: Int = 12
    
    private var algorandService: AlgorandService?
    
    var formattedBalance: String {
        String(format: "%.2f", asaBalance)
    }
    
    var formattedAlgoBalance: String {
        String(format: "%.3f", algoBalance)
    }
    
    var formattedSavings: String {
        String(format: "%.2f", savingsBalance)
    }
    
    var formattedLocked: String {
        String(format: "%.2f", lockedBalance)
    }
    
    var formattedIntegrityScore: String {
        String(format: "%.1f", spendingIntegrityScore)
    }
    
    var integrityScoreLevel: String {
        switch spendingIntegrityScore {
        case 9.0...10.0: return "Exceptional"
        case 8.0..<9.0: return "Excellent"
        case 7.0..<8.0: return "Good"
        case 6.0..<7.0: return "Fair"
        case 5.0..<6.0: return "Needs Improvement"
        default: return "Poor"
        }
    }
    
    var integrityScoreColor: String {
        switch spendingIntegrityScore {
        case 9.0...10.0: return "green"
        case 8.0..<9.0: return "blue" 
        case 7.0..<8.0: return "teal"
        case 6.0..<7.0: return "orange"
        case 5.0..<6.0: return "red"
        default: return "red"
        }
    }
    
    // Calculate spending integrity based on recent transactions
    func calculateSpendingIntegrityScore() {
        let approvedTransactions = recentTransactions.filter { $0.status == .approved }
        guard !approvedTransactions.isEmpty else {
            spendingIntegrityScore = 5.0
            return
        }
        
        let averageIntegrity = approvedTransactions.compactMap { transaction -> Double? in
            guard let justification = transaction.purchaseJustification else { return 1.0 }
            return transaction.spendingIntegrityScore * justification.integrityMultiplier
        }.reduce(0, +) / Double(approvedTransactions.count)
        
        // Factor in merchant reputation scores
        let averageMerchantScore = approvedTransactions.map { $0.merchantReputationScore }.reduce(0, +) / Double(approvedTransactions.count)
        
        // Weight: 60% purchase integrity, 30% merchant reputation, 10% consistency
        let consistencyBonus = goodSpendingStreak > 10 ? 0.5 : Double(goodSpendingStreak) * 0.05
        
        spendingIntegrityScore = min(10.0, (averageIntegrity * 0.6) + (averageMerchantScore * 0.3) + (7.0 * 0.1) + consistencyBonus)
    }
    
    func setAlgorandService(_ service: AlgorandService) {
        self.algorandService = service
        
        // Observe balance changes from AlgorandService
        service.$asaBalance
            .assign(to: &$asaBalance)
        
        service.$balance
            .assign(to: &$algoBalance)
    }
    
    init() {
        loadMockData()
    }
    
    func refreshBalance() async {
        isLoading = true
        
        // Get real balance from Algorand service
        await algorandService?.refreshBalance()
        
        isLoading = false
    }
    
    func loadTransactionHistory() async {
        isLoading = true
        
        // Simulate fetching transaction history
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        recentTransactions = [
            Transaction(
                id: UUID().uuidString,
                merchant: "Khan Academy",
                category: "Education",
                amount: 15.99,
                date: Date().addingTimeInterval(-3600),
                status: .approved,
                transactionHash: "DEMO" + UUID().uuidString.prefix(10),
                note: "Premium subscription",
                purchaseJustification: .education,
                merchantReputationScore: 9.8,
                spendingIntegrityScore: 9.2,
                verificationProofs: [
                    VerificationProof(type: .merchantReputation, result: .passed, details: "Merchant has excellent reputation (9.8/10)", timestamp: Date(), blockchainHash: "0xABC123"),
                    VerificationProof(type: .categoryRestriction, result: .passed, details: "Educational purchases are encouraged", timestamp: Date(), blockchainHash: "0xDEF456"),
                    VerificationProof(type: .spendingLimit, result: .passed, details: "Within daily limit", timestamp: Date(), blockchainHash: nil)
                ]
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "Community Charity",
                category: "Charity",
                amount: 25.00,
                date: Date().addingTimeInterval(-7200),
                status: .approved,
                transactionHash: "DEMO" + UUID().uuidString.prefix(10),
                note: "Local food bank donation",
                purchaseJustification: .charity,
                merchantReputationScore: 9.7,
                spendingIntegrityScore: 9.8,
                verificationProofs: [
                    VerificationProof(type: .merchantReputation, result: .passed, details: "Verified 501(c)(3) charity", timestamp: Date(), blockchainHash: "0xGHI789"),
                    VerificationProof(type: .fraudDetection, result: .passed, details: "No fraud indicators detected", timestamp: Date(), blockchainHash: nil)
                ]
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "Amazon",
                category: "Shopping", 
                amount: 24.99,
                date: Date().addingTimeInterval(-14400),
                status: .approved,
                transactionHash: "DEMO" + UUID().uuidString.prefix(10),
                note: "School supplies",
                purchaseJustification: .necessity,
                merchantReputationScore: 9.2,
                spendingIntegrityScore: 8.1,
                verificationProofs: [
                    VerificationProof(type: .merchantReputation, result: .passed, details: "Well-known retailer with good reputation", timestamp: Date(), blockchainHash: "0xJKL012"),
                    VerificationProof(type: .patternAnalysis, result: .passed, details: "Purchase aligns with school season", timestamp: Date(), blockchainHash: nil)
                ]
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "Steam",
                category: "Gaming",
                amount: 59.99,
                date: Date().addingTimeInterval(-21600),
                status: .rejected,
                transactionHash: nil,
                note: "Category restricted by parent",
                purchaseJustification: nil,
                merchantReputationScore: 8.5,
                spendingIntegrityScore: 3.0,
                verificationProofs: [
                    VerificationProof(type: .categoryRestriction, result: .failed, details: "Gaming category is blocked by parental controls", timestamp: Date(), blockchainHash: nil),
                    VerificationProof(type: .parentalApproval, result: .failed, details: "Parent has blocked gaming purchases", timestamp: Date(), blockchainHash: nil)
                ]
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "ShadyDealsOnline",
                category: "Shopping",
                amount: 89.99,
                date: Date().addingTimeInterval(-28800),
                status: .rejected,
                transactionHash: nil,
                note: "Merchant flagged as fraudulent",
                purchaseJustification: nil,
                merchantReputationScore: 1.2,
                spendingIntegrityScore: 1.0,
                verificationProofs: [
                    VerificationProof(type: .merchantReputation, result: .failed, details: "Merchant flagged with multiple fraud reports", timestamp: Date(), blockchainHash: nil),
                    VerificationProof(type: .fraudDetection, result: .failed, details: "Merchant on fraud blacklist", timestamp: Date(), blockchainHash: nil)
                ]
            )
        ]
        
        // Calculate spending integrity score based on transactions
        calculateSpendingIntegrityScore()
        totalVerifiedPurchases = recentTransactions.filter { $0.status == .approved }.count
        
        isLoading = false
    }
    
    private func loadMockData() {
        Task {
            await loadTransactionHistory()
        }
    }
    
    func processSpend(amount: Double, merchant: String, category: String) async -> Bool {
        guard amount <= asaBalance else { return false }
        
        // Check parent-set rules
        if isRestrictedCategory(category) {
            return false
        }
        
        if amount > getDailyLimit() {
            return false
        }
        
        // Process the transaction
        asaBalance -= amount
        
        let newTransaction = Transaction(
            id: UUID().uuidString,
            merchant: merchant,
            category: category,
            amount: amount,
            date: Date(),
            status: .approved,
            transactionHash: "DEMO" + UUID().uuidString.prefix(10),
            note: nil,
            purchaseJustification: .necessity,
            merchantReputationScore: 8.0,
            spendingIntegrityScore: 7.5,
            verificationProofs: []
        )
        
        recentTransactions.insert(newTransaction, at: 0)
        
        return true
    }
    
    private func isRestrictedCategory(_ category: String) -> Bool {
        let restricted = ["Gaming", "Gambling", "Adult Content"]
        return restricted.contains(category)
    }
    
    private func getDailyLimit() -> Double {
        return 50.0 // 50 ALGO daily limit for demo
    }
    
    func lockFunds(amount: Double, days: Int) async -> Bool {
        guard amount <= asaBalance else { return false }
        
        asaBalance -= amount
        lockedBalance += amount
        
        // In production, this would create a timelock smart contract
        // For demo, we're just updating the UI
        
        return true
    }
}