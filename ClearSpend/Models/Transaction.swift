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
        }
    }
}

// MARK: - Verification System

struct VerificationProof: Identifiable, Codable {
    let id = UUID()
    let type: VerificationType
    let result: VerificationResult
    let details: String
    let timestamp: Date
    let blockchainHash: String?
    
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

// MARK: - Enhanced Merchant System

struct ApprovedMerchant: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let isVerified: Bool
    let reputationScore: Double
    let businessLicenseVerified: Bool
    let communityRating: Double
    let trustLevel: TrustLevel
    let verificationDate: Date
    let dailyLimit: Double
    let monthlyTransactions: Int
    let fraudReports: Int
    
    enum TrustLevel: String, CaseIterable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case caution = "Caution"
        case blocked = "Blocked"
        
        var color: String {
            switch self {
            case .excellent: return "green"
            case .good: return "blue"
            case .fair: return "yellow"
            case .caution: return "orange"
            case .blocked: return "red"
            }
        }
        
        var score: Double {
            switch self {
            case .excellent: return 9.5
            case .good: return 8.0
            case .fair: return 6.5
            case .caution: return 4.0
            case .blocked: return 0.0
            }
        }
    }
    
    var overallScore: Double {
        return (reputationScore * 0.4 + communityRating * 0.3 + trustLevel.score * 0.3)
    }
    
    static let examples = [
        ApprovedMerchant(
            name: "Amazon",
            category: "Shopping", 
            icon: "cart.fill",
            isVerified: true,
            reputationScore: 9.2,
            businessLicenseVerified: true,
            communityRating: 8.8,
            trustLevel: .excellent,
            verificationDate: Date().addingTimeInterval(-30*24*60*60),
            dailyLimit: 200.0,
            monthlyTransactions: 45,
            fraudReports: 0
        ),
        ApprovedMerchant(
            name: "Khan Academy",
            category: "Education",
            icon: "book.fill",
            isVerified: true,
            reputationScore: 9.8,
            businessLicenseVerified: true,
            communityRating: 9.9,
            trustLevel: .excellent,
            verificationDate: Date().addingTimeInterval(-45*24*60*60),
            dailyLimit: 100.0,
            monthlyTransactions: 23,
            fraudReports: 0
        ),
        ApprovedMerchant(
            name: "Spotify",
            category: "Entertainment",
            icon: "music.note",
            isVerified: true,
            reputationScore: 8.5,
            businessLicenseVerified: true,
            communityRating: 8.7,
            trustLevel: .good,
            verificationDate: Date().addingTimeInterval(-20*24*60*60),
            dailyLimit: 50.0,
            monthlyTransactions: 12,
            fraudReports: 0
        ),
        ApprovedMerchant(
            name: "Local Food Mart",
            category: "Food",
            icon: "cart.fill",
            isVerified: true,
            reputationScore: 7.2,
            businessLicenseVerified: true,
            communityRating: 7.8,
            trustLevel: .good,
            verificationDate: Date().addingTimeInterval(-10*24*60*60),
            dailyLimit: 75.0,
            monthlyTransactions: 8,
            fraudReports: 1
        ),
        ApprovedMerchant(
            name: "Community Charity",
            category: "Charity",
            icon: "hand.raised.fill",
            isVerified: true,
            reputationScore: 9.7,
            businessLicenseVerified: true,
            communityRating: 9.8,
            trustLevel: .excellent,
            verificationDate: Date().addingTimeInterval(-60*24*60*60),
            dailyLimit: 500.0,
            monthlyTransactions: 3,
            fraudReports: 0
        )
    ]
}

