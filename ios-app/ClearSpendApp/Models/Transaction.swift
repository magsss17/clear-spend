import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let merchant: String
    let category: String
    let amount: Double
    let date: Date
    let status: TransactionStatus
    let transactionHash: String?
    let note: String?
    
    enum TransactionStatus: String, Codable, CaseIterable {
        case approved = "Approved"
        case rejected = "Rejected"
        case pending = "Pending"
    }
    
    var formattedAmount: String {
        String(format: "%.2f ALGO", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var explorerLink: String? {
        guard let hash = transactionHash else { return nil }
        return "https://testnet.algoexplorer.io/tx/\(hash)"
    }
}

struct PurchaseResult: Identifiable {
    let id = UUID()
    let success: Bool
    let message: String
    let transactionId: String?
    let explorerLink: String?
}

struct ApprovedMerchant: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let isVerified: Bool
    
    static let examples = [
        ApprovedMerchant(name: "Amazon", category: "Shopping", icon: "cart.fill", isVerified: true),
        ApprovedMerchant(name: "Spotify", category: "Entertainment", icon: "music.note", isVerified: true),
        ApprovedMerchant(name: "Khan Academy", category: "Education", icon: "book.fill", isVerified: true),
        ApprovedMerchant(name: "Uber", category: "Transportation", icon: "car.fill", isVerified: true),
        ApprovedMerchant(name: "Steam", category: "Gaming", icon: "gamecontroller.fill", isVerified: true)
    ]
}
