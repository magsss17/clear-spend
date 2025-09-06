import SwiftUI

struct SpendView: View {
    @EnvironmentObject var algorandService: AlgorandService
    @EnvironmentObject var walletViewModel: WalletViewModel
    @State private var merchantName = ""
    @State private var amount = ""
    @State private var category = "Shopping"
    @State private var purchaseJustification: PurchaseJustification = .necessity
    @State private var showingPurchaseConfirmation = false
    @State private var purchaseResult: PurchaseResult?
    @State private var isProcessing = false
    @State private var showingJustificationDetail = false
    
    let categories = ["Shopping", "Food", "Entertainment", "Education", "Transportation", "Gaming"]
    let fraudulentMerchants = ["ShadyDealsOnline", "FakeGameStore", "UnverifiedShop"]
    let restrictedMerchants = ["GameStop", "Steam", "PlayStation Store"] // Gaming is blocked
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    availableBalanceCard
                    
                    fraudPreventionStatus
                    
                    purchaseForm
                    
                    categorySelector
                    
                    purchaseJustificationSelector
                    
                    purchaseButton
                    
                    merchantSuggestions
                    
                    recentBlockedPurchases
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Spend")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $purchaseResult) { result in
                PurchaseResultView(result: result)
            }
            .background(Color.white)
        }
    }
    
    private var availableBalanceCard: some View {
        VStack(spacing: 8) {
            Text("Available to Spend")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(walletViewModel.formattedBalance) ALGO")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.purple)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
    
    private var purchaseForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Make a Purchase")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Merchant")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("Enter merchant name", text: $merchantName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount (ALGO)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { cat in
                        CategoryChip(
                            title: cat,
                            isSelected: category == cat,
                            icon: categoryIcon(for: cat)
                        ) {
                            category = cat
                        }
                    }
                }
            }
        }
    }
    
    private var purchaseJustificationSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.blue)
                Text("Purchase Justification")
                    .font(.headline)
                Spacer()
                Button("Why Required?") {
                    showingJustificationDetail = true
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: purchaseJustification.icon)
                        .foregroundColor(.purple)
                        .frame(width: 25)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(purchaseJustification.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(purchaseJustification.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("+\(String(format: "%.1f", (purchaseJustification.integrityMultiplier - 1.0) * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                .onTapGesture {
                    // Show justification picker
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PurchaseJustification.allCases, id: \.self) { justification in
                            JustificationChip(
                                justification: justification,
                                isSelected: purchaseJustification == justification
                            ) {
                                purchaseJustification = justification
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        .sheet(isPresented: $showingJustificationDetail) {
            PurchaseJustificationInfoView()
        }
    }
    
    private var purchaseButton: some View {
        Button(action: processPurchase) {
            if isProcessing {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Processing...")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("Verify & Purchase")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple, Color.purple.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .foregroundColor(.white)
        .cornerRadius(12)
        .disabled(merchantName.isEmpty || amount.isEmpty || isProcessing)
        .opacity((merchantName.isEmpty || amount.isEmpty) ? 0.6 : 1.0)
    }
    
    private var merchantSuggestions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Verified Merchants")
                    .font(.headline)
                Spacer()
                Text("Reputation Score")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ForEach(ApprovedMerchant.examples, id: \.id) { merchant in
                HStack {
                    Image(systemName: merchant.icon)
                        .foregroundColor(.purple)
                        .frame(width: 40, height: 40)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(merchant.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if merchant.businessLicenseVerified {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            Text(merchant.category)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text("\(merchant.monthlyTransactions) transactions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text(merchant.trustLevel.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Color(merchant.trustLevel.color))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(merchant.trustLevel.color).opacity(0.1))
                                .cornerRadius(4)
                            
                            if merchant.fraudReports > 0 {
                                Text("\(merchant.fraudReports) fraud reports")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", merchant.overallScore))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(merchant.trustLevel.color))
                        
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(index < Int(merchant.overallScore / 2) ? Color(merchant.trustLevel.color) : Color.gray.opacity(0.3))
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(merchant.trustLevel.color).opacity(0.3), lineWidth: 1)
                )
                .onTapGesture {
                    merchantName = merchant.name
                    category = merchant.category
                    // Auto-select appropriate justification based on merchant category
                    switch merchant.category {
                    case "Education":
                        purchaseJustification = .education
                    case "Charity":
                        purchaseJustification = .charity
                    case "Health & Wellness":
                        purchaseJustification = .health_wellness
                    case "Transportation":
                        purchaseJustification = .transportation
                    default:
                        purchaseJustification = .necessity
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private func processPurchase() {
        isProcessing = true
        
        Task {
            let result = await algorandService.processPurchase(
                merchant: merchantName,
                amount: Double(amount) ?? 0,
                category: category
            )
            
            await MainActor.run {
                purchaseResult = result
                isProcessing = false
                if result.success {
                    clearForm()
                    Task {
                        await walletViewModel.refreshBalance()
                    }
                }
            }
        }
    }
    
    private func clearForm() {
        merchantName = ""
        amount = ""
        category = "Shopping"
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Shopping": return "bag.fill"
        case "Food": return "fork.knife"
        case "Entertainment": return "tv.fill"
        case "Education": return "book.fill"
        case "Transportation": return "car.fill"
        case "Gaming": return "gamecontroller.fill"
        default: return "tag.fill"
        }
    }
    
    private var fraudPreventionStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered.fill")
                    .foregroundColor(.blue)
                Text("Fraud Prevention Active")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            Text("Every purchase verified via atomic transfers before payment")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var recentBlockedPurchases: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Fraud Prevention")
                .font(.headline)
            
            VStack(spacing: 12) {
                blockedPurchaseRow(
                    merchant: "ShadyDealsOnline",
                    amount: "$59.99",
                    reason: "Unverified merchant",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                
                blockedPurchaseRow(
                    merchant: "GameStop",
                    amount: "$79.99",
                    reason: "Gaming category blocked",
                    icon: "xmark.circle.fill",
                    color: .orange
                )
                
                blockedPurchaseRow(
                    merchant: "FakeGameStore",
                    amount: "$39.99",
                    reason: "Fraudulent merchant detected",
                    icon: "shield.slash.fill",
                    color: .red
                )
            }
            
            HStack {
                Text("Total fraud prevented:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("$179.97")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private func blockedPurchaseRow(merchant: String, amount: String, reason: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(merchant)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(amount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .strikethrough()
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct JustificationChip: View {
    let justification: PurchaseJustification
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: justification.icon)
                    .font(.caption2)
                Text(justification.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct PurchaseJustificationInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Why Purchase Justification Matters")
                            .font(.headline)
                        
                        Text("To build trust and credit worthiness, ClearSpend requires teens to justify their spending decisions. This helps:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        justificationBenefit(
                            icon: "shield.checkered.fill",
                            title: "Prevent Impulsive Purchases",
                            description: "Thinking about why you need something reduces impulse buying"
                        )
                        
                        justificationBenefit(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Build Credit Score",
                            description: "Good spending justifications improve your credit building score"
                        )
                        
                        justificationBenefit(
                            icon: "hand.raised.fill",
                            title: "Parental Trust",
                            description: "Parents can see you're making thoughtful spending decisions"
                        )
                        
                        justificationBenefit(
                            icon: "graduationcap.fill",
                            title: "Financial Education",
                            description: "Develops critical thinking about money and spending"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Justification Impact on Credit Score")
                            .font(.headline)
                        
                        ForEach(PurchaseJustification.allCases, id: \.self) { justification in
                            HStack {
                                Image(systemName: justification.icon)
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(justification.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(justification.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("+\(String(format: "%.0f", (justification.integrityMultiplier - 1.0) * 100))%")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Purchase Justification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func justificationBenefit(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    SpendView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}
