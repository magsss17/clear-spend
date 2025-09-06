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

struct LearningModule: Identifiable {
    let id = UUID()
    let title: String
    let lessons: Int
    let duration: String
    let progress: Double
    let icon: String
    
    static let examples = [
        LearningModule(title: "Budgeting Basics", lessons: 5, duration: "30 min", progress: 0.8, icon: "chart.pie.fill"),
        LearningModule(title: "Smart Saving", lessons: 7, duration: "45 min", progress: 0.6, icon: "banknote"),
        LearningModule(title: "Intro to Investing", lessons: 10, duration: "1 hour", progress: 0.3, icon: "chart.line.uptrend.xyaxis"),
        LearningModule(title: "Understanding Credit", lessons: 6, duration: "40 min", progress: 0.0, icon: "creditcard.fill"),
        LearningModule(title: "Crypto 101", lessons: 8, duration: "50 min", progress: 1.0, icon: "bitcoinsign.circle.fill")
    ]
}