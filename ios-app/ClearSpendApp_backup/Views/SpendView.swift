import SwiftUI

struct SpendView: View {
    @EnvironmentObject var algorandService: AlgorandService
    @EnvironmentObject var walletViewModel: WalletViewModel
    @State private var merchantName = ""
    @State private var amount = ""
    @State private var category = "Shopping"
    @State private var showingPurchaseConfirmation = false
    @State private var purchaseResult: PurchaseResult?
    @State private var isProcessing = false
    
    let categories = ["Shopping", "Food", "Entertainment", "Education", "Transportation", "Gaming"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    availableBalanceCard
                    
                    purchaseForm
                    
                    categorySelector
                    
                    purchaseButton
                    
                    merchantSuggestions
                }
                .padding()
            }
            .navigationTitle("Spend")
            .sheet(item: $purchaseResult) { result in
                PurchaseResultView(result: result)
            }
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
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(12)
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
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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
            Text("Approved Merchants")
                .font(.headline)
            
            ForEach(ApprovedMerchant.examples, id: \.id) { merchant in
                HStack {
                    Image(systemName: merchant.icon)
                        .foregroundColor(.purple)
                        .frame(width: 40, height: 40)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(merchant.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(merchant.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .onTapGesture {
                    merchantName = merchant.name
                    category = merchant.category
                }
            }
        }
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

#Preview {
    SpendView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}