import Foundation
import Combine

@MainActor
class AlgorandService: ObservableObject {
    @Published var isConnected = false
    @Published var currentAddress: String?
    @Published var balance: Double = 0
    @Published var asaBalance: Double = 150.0 // ALGO balance
    
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
        asaBalance = 150.0 // ALGO balance
        isConnected = true
    }
    
    func refreshBalance() async {
        // Simulate balance refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        // In a real implementation, this would fetch from blockchain
        asaBalance = 150.0
        balance = 150.0
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
    
    func fetchMerchants() async -> [ApprovedMerchant] {
        guard let url = URL(string: "\(backendURL)/api/v1/merchants/") else {
            print("❌ Invalid URL for fetching merchants")
            return ApprovedMerchant.examples
        }
        
        do {
            print("🔄 Fetching merchants from: \(url)")
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Response status: \(httpResponse.statusCode)")
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString)")
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("📊 Parsed JSON keys: \(json.keys)")
                
                if let merchants = json["merchants"] as? [[String: Any]] {
                    print("✅ Found \(merchants.count) merchants")
                    
                    let approvedMerchants = merchants.compactMap { merchantData -> ApprovedMerchant? in
                        guard let name = merchantData["merchant_name"] as? String,
                              let category = merchantData["category"] as? String,
                              let isApproved = merchantData["is_approved"] as? Bool,
                              let parentApproved = merchantData["parent_approved"] as? Bool,
                              let dailyLimit = merchantData["daily_limit"] as? Int,
                              let totalSpentToday = merchantData["total_spent_today"] as? Int,
                              let lastUpdate = merchantData["last_update"] as? Int else {
                            print("❌ Failed to parse merchant data: \(merchantData)")
                            return nil
                        }
                        
                        print("✅ Parsed merchant: \(name) (\(category))")
                        
                        return ApprovedMerchant(
                            name: name,
                            category: category,
                            icon: "", // Will use computed property
                            isVerified: true,
                            reputationScore: 8.0,
                            businessLicenseVerified: true,
                            communityRating: 8.0,
                            trustLevel: .good,
                            verificationDate: Date(),
                            dailyLimit: Double(dailyLimit),
                            monthlyTransactions: 10,
                            fraudReports: 0,
                            isApproved: isApproved,
                            parentApproved: parentApproved,
                            totalSpentToday: totalSpentToday,
                            lastUpdate: lastUpdate
                        )
                    }
                    
                    print("🎯 Returning \(approvedMerchants.count) approved merchants")
                    return approvedMerchants
                } else {
                    print("❌ No 'merchants' key found in response")
                }
            } else {
                print("❌ Failed to parse JSON response")
            }
        } catch {
            print("❌ Error fetching merchants: \(error)")
        }
        
        print("🔄 Falling back to example merchants")
        return ApprovedMerchant.examples
    }
    
    func addMerchant(name: String, category: String, dailyLimit: Int) async -> Bool {
        guard let url = URL(string: "\(backendURL)/api/v1/merchants/") else {
            print("❌ Invalid URL for adding merchant")
            return false
        }
        
        let requestData: [String: Any] = [
            "merchant_name": name,
            "category": category,
            "is_approved": true,
            "daily_limit": dailyLimit,
            "parent_approved": true
        ]
        
        print("🔄 Adding merchant: \(name) (\(category)) with limit: \(dailyLimit)")
        print("📤 Request data: \(requestData)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Add merchant response status: \(httpResponse.statusCode)")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Add merchant response: \(responseString)")
                }
                
                return httpResponse.statusCode == 200
            }
        } catch {
            print("❌ Error adding merchant: \(error)")
        }
        
        return false
    }
    
    func updateParentApproval(merchantName: String, approved: Bool) async -> Bool {
        guard let url = URL(string: "\(backendURL)/api/v1/merchants/\(merchantName)/parent-approval") else {
            return false
        }
        
        let requestData: [String: Any] = [
            "merchant_name": merchantName,
            "approved": approved
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData)
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Error updating parent approval: \(error)")
        }
        
        return false
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
                note: "Monthly subscription",
                purchaseJustification: .approved_leisure,
                merchantReputationScore: 8.5,
                spendingIntegrityScore: 8.0,
                verificationProofs: []
            ),
            Transaction(
                id: "2",
                merchant: "Amazon",
                category: "Shopping",
                amount: 24.99,
                date: Date().addingTimeInterval(-172800),
                status: .approved,
                transactionHash: generateMockTransactionId(),
                note: "School supplies",
                purchaseJustification: .necessity,
                merchantReputationScore: 9.2,
                spendingIntegrityScore: 8.5,
                verificationProofs: []
            ),
            Transaction(
                id: "3",
                merchant: "GameStop",
                category: "Gaming",
                amount: 59.99,
                date: Date().addingTimeInterval(-259200),
                status: .rejected,
                transactionHash: nil,
                note: "Category restricted",
                purchaseJustification: nil,
                merchantReputationScore: 7.5,
                spendingIntegrityScore: 3.0,
                verificationProofs: []
            )
        ]
    }
}