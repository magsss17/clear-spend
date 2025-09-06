import Foundation
import Combine

@MainActor
class AlgorandService: ObservableObject {
    @Published var isConnected = false
    @Published var currentAddress: String?
    @Published var balance: Double = 0
    
    private let testnetURL = "https://testnet-api.algonode.cloud"
    private let testnetIndexer = "https://testnet-idx.algonode.cloud"
    
    // Backend API configuration
    private let backendURL = "http://localhost:8000"
    
    // Demo wallet for hackathon
    private let demoAddress = "DEMO7XQVZQHGZPWXZQHGZQVZQHGZPWXZQHGZQVZQHGZPWXZQHGZQVZQHGZ"
    private let demoMnemonic = "demo seed phrase for hackathon testing only do not use in production"
    
    init() {
        setupDemoWallet()
    }
    
    private func setupDemoWallet() {
        // For hackathon demo - using mock data
        currentAddress = demoAddress
        balance = 150.0 // Demo balance in ALGO
        isConnected = true
    }
    
    func processPurchase(merchant: String, amount: Double, category: String) async -> PurchaseResult {
        // Call real backend API for purchase verification
        return await verifyPurchaseWithBackend(merchant: merchant, amount: amount, category: category)
    }
    
    private func verifyPurchaseWithBackend(merchant: String, amount: Double, category: String) async -> PurchaseResult {
        guard let url = URL(string: "\(backendURL)/api/v1/purchases/verify") else {
            return PurchaseResult(
                success: false,
                message: "Invalid API URL",
                transactionId: nil,
                explorerLink: nil
            )
        }
        
        let requestData: [String: Any] = [
            "merchant_name": merchant,
            "amount": Int(amount * 1_000_000), // Convert to microALGO
            "user_address": demoAddress
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let approved = json["approved"] as? Bool ?? false
                    let reason = json["reason"] as? String
                    let transactionId = json["transaction_id"] as? String
                    let explorerLink = json["explorer_link"] as? String
                    
                    if approved {
                        // Update balance on successful purchase
                        balance -= amount
                        
                        return PurchaseResult(
                            success: true,
                            message: "Purchase approved! Transaction complete.",
                            transactionId: transactionId,
                            explorerLink: explorerLink
                        )
                    } else {
                        return PurchaseResult(
                            success: false,
                            message: reason ?? "Purchase denied by backend verification.",
                            transactionId: nil,
                            explorerLink: nil
                        )
                    }
                }
            }
            
            // Fallback to mock if backend fails
            return await fallbackToMockVerification(merchant: merchant, amount: amount, category: category)
            
        } catch {
            print("Backend API error: \(error)")
            // Fallback to mock verification
            return await fallbackToMockVerification(merchant: merchant, amount: amount, category: category)
        }
    }
    
    private func fallbackToMockVerification(merchant: String, amount: Double, category: String) async -> PurchaseResult {
        // Simulate atomic transfer verification
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay for demo
        
        // Check if purchase is approved based on category and amount
        let isApproved = checkPurchaseApproval(category: category, amount: amount)
        
        if isApproved {
            // Simulate successful transaction
            let mockTxId = generateMockTransactionId()
            balance -= amount
            
            return PurchaseResult(
                success: true,
                message: "Purchase approved! (Mock verification)",
                transactionId: mockTxId,
                explorerLink: "https://testnet.algoexplorer.io/tx/\(mockTxId)"
            )
        } else {
            return PurchaseResult(
                success: false,
                message: "Purchase denied. Category '\(category)' is restricted or amount exceeds limit.",
                transactionId: nil,
                explorerLink: nil
            )
        }
    }
    
    private func checkPurchaseApproval(category: String, amount: Double) -> Bool {
        // Demo rules for purchase approval
        let restrictedCategories = ["Gaming", "Gambling"]
        let dailyLimit: Double = 50.0
        
        if restrictedCategories.contains(category) {
            return false
        }
        
        if amount > dailyLimit {
            return false
        }
        
        if amount > balance {
            return false
        }
        
        return true
    }
    
    func createAtomicTransfer(merchant: String, amount: Double, attestationRequired: Bool) async throws {
        // This would create an atomic transfer group with:
        // 1. App call to check attestation
        // 2. ASA transfer to merchant
        // For demo, we're using mock implementation
    }
    
    func fetchAttestationStatus(for merchant: String) async -> Bool {
        // Check if merchant has valid attestation in smart contract
        // For demo, returning true for approved merchants
        let approvedMerchants = ["Amazon", "Spotify", "Khan Academy", "Uber"]
        return approvedMerchants.contains(merchant)
    }
    
    func fetchMerchants() async -> [String: [String: Any]] {
        guard let url = URL(string: "\(backendURL)/api/v1/merchants/") else {
            return [:]
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                return json
            }
        } catch {
            print("Error fetching merchants: \(error)")
        }
        
        return [:]
    }
    
    private func generateMockTransactionId() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        return String((0..<52).map { _ in letters.randomElement()! })
    }
    
    func getTransactionHistory() async -> [Transaction] {
        // Return mock transaction history
        return [
            Transaction(
                id: "1",
                merchant: "Spotify",
                category: "Entertainment",
                amount: 9.99,
                date: Date().addingTimeInterval(-86400),
                status: .approved,
                transactionHash: generateMockTransactionId(),
                note: "Monthly subscription"
            ),
            Transaction(
                id: "2",
                merchant: "Amazon",
                category: "Shopping",
                amount: 24.99,
                date: Date().addingTimeInterval(-172800),
                status: .approved,
                transactionHash: generateMockTransactionId(),
                note: "School supplies"
            ),
            Transaction(
                id: "3",
                merchant: "GameStop",
                category: "Gaming",
                amount: 59.99,
                date: Date().addingTimeInterval(-259200),
                status: .rejected,
                transactionHash: nil,
                note: "Category restricted"
            )
        ]
    }
}