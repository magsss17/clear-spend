import Foundation

struct ApprovedMerchant: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var category: String
    var icon: String
    var isActive: Bool = true
    var addedDate: Date = Date()
    
    static var examples: [ApprovedMerchant] {
        [
            ApprovedMerchant(name: "Khan Academy", category: "Education", icon: "book.fill"),
            ApprovedMerchant(name: "Amazon", category: "Shopping", icon: "bag.fill"),
            ApprovedMerchant(name: "Spotify", category: "Entertainment", icon: "music.note"),
            ApprovedMerchant(name: "Community Charity", category: "Charity", icon: "heart.fill"),
            ApprovedMerchant(name: "Lofty Real Estate", category: "Investment", icon: "chart.line.uptrend.xyaxis"),
            ApprovedMerchant(name: "xAlgo", category: "Investment", icon: "chart.line.uptrend.xyaxis"),
            ApprovedMerchant(name: "Valar", category: "Investment", icon: "chart.line.uptrend.xyaxis")
        ]
    }
    
    static func getCategoryIcon(for category: String) -> String {
        switch category {
        case "Shopping": return "bag.fill"
        case "Food": return "fork.knife"
        case "Entertainment": return "music.note"
        case "Education": return "book.fill"
        case "Transportation": return "car.fill"
        case "Gaming": return "gamecontroller.fill"
        case "Investment": return "chart.line.uptrend.xyaxis"
        case "Charity": return "heart.fill"
        default: return "tag.fill"
        }
    }
}

class MerchantManager: ObservableObject {
    @Published var approvedMerchants: [ApprovedMerchant] = ApprovedMerchant.examples
    @Published var restrictedCategories: Set<String> = ["Gaming", "Gambling", "Adult Content"]
    @Published var dailyLimit: Double = 50.0
    
    func addMerchant(_ merchant: ApprovedMerchant) {
        approvedMerchants.append(merchant)
        saveMerchants()
    }
    
    func removeMerchant(at offsets: IndexSet) {
        approvedMerchants.remove(atOffsets: offsets)
        saveMerchants()
    }
    
    func updateMerchant(_ merchant: ApprovedMerchant) {
        if let index = approvedMerchants.firstIndex(where: { $0.id == merchant.id }) {
            approvedMerchants[index] = merchant
            saveMerchants()
        }
    }
    
    func toggleMerchantStatus(_ merchant: ApprovedMerchant) {
        if let index = approvedMerchants.firstIndex(where: { $0.id == merchant.id }) {
            approvedMerchants[index].isActive.toggle()
            saveMerchants()
        }
    }
    
    func addRestrictedCategory(_ category: String) {
        restrictedCategories.insert(category)
        saveRestrictions()
    }
    
    func removeRestrictedCategory(_ category: String) {
        restrictedCategories.remove(category)
        saveRestrictions()
    }
    
    func isMerchantApproved(_ merchantName: String) -> Bool {
        return approvedMerchants.contains { merchant in
            merchant.isActive && merchant.name.lowercased() == merchantName.lowercased()
        }
    }
    
    func isCategoryRestricted(_ category: String) -> Bool {
        return restrictedCategories.contains(category)
    }
    
    func isPurchaseAllowed(merchant: String, category: String, amount: Double) -> Bool {
        // Check daily limit
        if amount > dailyLimit {
            return false
        }
        
        // Check if category is restricted
        if isCategoryRestricted(category) {
            return false
        }
        
        // If merchant is in approved list, allow it
        if isMerchantApproved(merchant) {
            return true
        }
        
        // Default allow for non-restricted categories under limit
        return !isCategoryRestricted(category)
    }
    
    private func saveMerchants() {
        // In production, save to UserDefaults or Core Data
        if let encoded = try? JSONEncoder().encode(approvedMerchants) {
            UserDefaults.standard.set(encoded, forKey: "approvedMerchants")
        }
    }
    
    private func saveRestrictions() {
        UserDefaults.standard.set(Array(restrictedCategories), forKey: "restrictedCategories")
        UserDefaults.standard.set(dailyLimit, forKey: "dailyLimit")
    }
    
    private func loadMerchants() {
        if let data = UserDefaults.standard.data(forKey: "approvedMerchants"),
           let decoded = try? JSONDecoder().decode([ApprovedMerchant].self, from: data) {
            approvedMerchants = decoded
        }
    }
    
    private func loadRestrictions() {
        if let categories = UserDefaults.standard.array(forKey: "restrictedCategories") as? [String] {
            restrictedCategories = Set(categories)
        }
        let limit = UserDefaults.standard.double(forKey: "dailyLimit")
        if limit > 0 {
            dailyLimit = limit
        }
    }
    
    init() {
        loadMerchants()
        loadRestrictions()
        
        // If no saved data, use defaults
        if approvedMerchants.isEmpty {
            approvedMerchants = ApprovedMerchant.examples
        }
        
        // Remove Shopping from restricted categories if it was previously added
        if restrictedCategories.contains("Shopping") {
            restrictedCategories.remove("Shopping")
            saveRestrictions()
        }
    }
}