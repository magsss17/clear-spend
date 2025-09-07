import Foundation
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var asaBalance: Double = 1.78 // ClearSpend Dollar balance - starts with realistic balance, syncs from testnet wallet
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
    private var cancellables = Set<AnyCancellable>()
    
    var formattedBalance: String {
        String(format: "%.2f", asaBalance)
    }
    
    var formattedBalanceWithDollar: String {
        "$" + String(format: "%.2f", asaBalance)
    }
    
    var formattedUsdcBalance: String {
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
            .receive(on: DispatchQueue.main)
            .assign(to: &$asaBalance)
        
        service.$balance
            .receive(on: DispatchQueue.main)
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
    
    func subtractFromBalance(_ amount: Double) {
        asaBalance = max(0, asaBalance - amount)
    }
    
    func addTransaction(_ result: PurchaseResult, merchant: String, category: String, amount: Double) {
        let newTransaction = Transaction(
            id: result.transactionId ?? UUID().uuidString,
            merchant: merchant,
            category: category,
            amount: amount,
            date: Date(),
            status: result.success ? .approved : .rejected,
            transactionHash: result.transactionId,
            note: result.success ? "Purchase completed" : result.message,
            purchaseJustification: .necessity,
            merchantReputationScore: 8.5,
            spendingIntegrityScore: spendingIntegrityScore,
            verificationProofs: []
        )
        
        // Add to beginning of recent transactions
        recentTransactions.insert(newTransaction, at: 0)
        
        // Keep only the most recent 20 transactions
        if recentTransactions.count > 20 {
            recentTransactions.removeLast()
        }
    }
    
    func loadTransactionHistory() async {
        isLoading = true
        
        // Simulate fetching transaction history
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        recentTransactions = [
            Transaction(
                id: UUID().uuidString,
                merchant: "Lofty Real Estate",
                category: "Investment",
                amount: 25.00,
                date: Date().addingTimeInterval(-1800),
                status: .approved,
                transactionHash: "PXUHIF3M7AA6ONMTBNRMATVEFWTFGQMHDKYRMAD5GI2GZLZJ62QQ",
                note: "Real estate investment",
                purchaseJustification: .investment,
                merchantReputationScore: 9.5,
                spendingIntegrityScore: 9.8,
                verificationProofs: [
                    VerificationProof(type: .merchantReputation, result: .passed, details: "Verified investment platform (9.5/10)", timestamp: Date(), blockchainHash: "0xINV123"),
                    VerificationProof(type: .categoryRestriction, result: .passed, details: "Investment purchases build wealth", timestamp: Date(), blockchainHash: "0xINV456"),
                    VerificationProof(type: .spendingLimit, result: .passed, details: "Smart investment decision", timestamp: Date(), blockchainHash: nil)
                ]
            ),
            Transaction(
                id: UUID().uuidString,
                merchant: "Khan Academy",
                category: "Education",
                amount: 5.00,
                date: Date().addingTimeInterval(-3600),
                status: .approved,
                transactionHash: "R4S437SWZTH2TGHJAFMKFIDOY4UJKPGJPNSO2OCV22GWSG4NTODA",
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
                amount: 5.00,
                date: Date().addingTimeInterval(-7200),
                status: .approved,
                transactionHash: "BWWLE2NRIMZ6REM5BWWFAEAM7SYREKPC655ICIVOPM4CEDLLVABQ",
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
                amount: 5.00,
                date: Date().addingTimeInterval(-14400),
                status: .approved,
                transactionHash: "IHZKLH4PGI25NYOJWQ3YOOXN66DIKYU3WWRGONRXURDEKEWQAMFA",
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
                amount: 5.00,
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
                amount: 5.00,
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
}