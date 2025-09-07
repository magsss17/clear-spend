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
    let purchaseJustification: PurchaseJustification?
    let merchantReputationScore: Double
    let spendingIntegrityScore: Double
    let verificationProofs: [VerificationProof]
    
    enum TransactionStatus: String, Codable, CaseIterable {
        case approved = "Approved"
        case rejected = "Rejected"
        case pending = "Pending"
        case requiresParentApproval = "Requires Parent Approval"
    }
    
    var formattedAmount: String {
        String(format: "$%.2f", amount)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy - h:mm a"
        return formatter.string(from: date)
    }
    
    var explorerLink: String? {
        guard let hash = transactionHash else { return nil }
        return "https://lora.algokit.io/testnet/transaction/\(hash)"
    }
}

struct PurchaseResult: Identifiable {
    let id = UUID()
    let success: Bool
    let message: String
    let transactionId: String?
    let explorerLink: String?
}

// MARK: - Purchase Justification System

enum PurchaseJustification: String, Codable, CaseIterable {
    case necessity = "Necessity"
    case education = "Educational"
    case approved_leisure = "Approved Leisure"
    case health_wellness = "Health & Wellness"
    case transportation = "Transportation"
    case charity = "Charity/Community"
    case family_approved = "Family Approved"
    case emergency = "Emergency"
    case investment = "Investment"
    
    var description: String {
        switch self {
        case .necessity: return "Essential item or service"
        case .education: return "Educational material or service"
        case .approved_leisure: return "Pre-approved recreational activity"
        case .health_wellness: return "Health, fitness, or wellness"
        case .transportation: return "Transportation need"
        case .charity: return "Charitable donation or community service"
        case .family_approved: return "Family-discussed purchase"
        case .emergency: return "Unexpected emergency expense"
        case .investment: return "Financial investment for future growth"
        }
    }
    
    var icon: String {
        switch self {
        case .necessity: return "house.fill"
        case .education: return "book.fill"
        case .approved_leisure: return "gamecontroller.fill"
        case .health_wellness: return "heart.fill"
        case .transportation: return "car.fill"
        case .charity: return "hand.raised.fill"
        case .family_approved: return "person.2.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var integrityMultiplier: Double {
        switch self {
        case .necessity: return 1.2
        case .education: return 1.5
        case .approved_leisure: return 1.0
        case .health_wellness: return 1.3
        case .transportation: return 1.1
        case .charity: return 1.8
        case .family_approved: return 1.1
        case .emergency: return 0.9
        case .investment: return 2.0
        }
    }
}

// MARK: - Verification System

struct VerificationProof: Identifiable, Codable {
    let id: UUID
    let type: VerificationType
    let result: VerificationResult
    let details: String
    let timestamp: Date
    let blockchainHash: String?
    
    init(type: VerificationType, result: VerificationResult, details: String, timestamp: Date, blockchainHash: String?) {
        self.id = UUID()
        self.type = type
        self.result = result
        self.details = details
        self.timestamp = timestamp
        self.blockchainHash = blockchainHash
    }
    
    enum VerificationType: String, Codable {
        case merchantReputation = "Merchant Reputation"
        case businessLicense = "Business License"
        case categoryRestriction = "Category Restriction"
        case spendingLimit = "Spending Limit"
        case parentalApproval = "Parental Approval"
        case geolocation = "Location Verification"
        case fraudDetection = "Fraud Detection"
        case patternAnalysis = "Spending Pattern"
    }
    
    enum VerificationResult: String, Codable {
        case passed = "Passed"
        case failed = "Failed"
        case warning = "Warning"
        case requiresReview = "Requires Review"
    }
    
    var icon: String {
        switch result {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .requiresReview: return "questionmark.circle.fill"
        }
    }
    
    var color: String {
        switch result {
        case .passed: return "green"
        case .failed: return "red"
        case .warning: return "orange"
        case .requiresReview: return "blue"
        }
    }
}


