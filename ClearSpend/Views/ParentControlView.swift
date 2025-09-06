import SwiftUI

struct ParentControlView: View {
    @EnvironmentObject var algorandService: AlgorandService
    @EnvironmentObject var walletViewModel: WalletViewModel
    
    @State private var selectedRestriction = "Gaming"
    @State private var dailyLimit = "50.00"
    @State private var showingAddMerchant = false
    @State private var newMerchantName = ""
    @State private var newMerchantCategory = "Shopping"
    @State private var allowanceAmount = "50.00"
    @State private var isPaused = false
    
    let categories = ["Shopping", "Food", "Entertainment", "Education", "Transportation", "Gaming"]
    let restrictedCategories = ["Gaming", "Gambling", "Adult Content"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    parentDashboard
                    
                    controlsSection
                    
                    restrictionsSection
                    
                    merchantSection
                    
                    transactionHistorySection
                }
                .padding()
            }
            .background(Color.white)
            .navigationTitle("Parent Controls")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddMerchant) {
                addMerchantSheet
            }
        }
        .background(Color.white)
    }
    
    private var parentDashboard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Teen's Allowance")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("\(walletViewModel.formattedBalance) ALGO")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Weekly Budget")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("$\(allowanceAmount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            Divider()
            
            HStack {
                Label("Testnet Address", systemImage: "link")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let address = algorandService.currentAddress {
                    Text(String(address.prefix(8)) + "...")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Controls")
                .font(.headline)
            
            HStack(spacing: 16) {
                Button(action: {
                    isPaused.toggle()
                }) {
                    HStack {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        Text(isPaused ? "Resume" : "Pause")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPaused ? Color.green : Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    Task {
                        await sendAllowance()
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Send Weekly")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            
            if isPaused {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Spending is currently paused")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private var restrictionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Restrictions")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Daily Limit")
                    Spacer()
                    TextField("0.00", text: $dailyLimit)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    Text("ALGO")
                        .foregroundColor(.gray)
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blocked Categories")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(restrictedCategories, id: \.self) { category in
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text(category)
                            Spacer()
                            Button("Remove") {
                                // Remove restriction logic
                            }
                            .font(.caption)
                            .foregroundColor(.purple)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
    }
    
    private var merchantSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Approved Merchants")
                    .font(.headline)
                
                Spacer()
                
                Button("Add Merchant") {
                    showingAddMerchant = true
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
            
            ForEach(ApprovedMerchant.examples, id: \.id) { merchant in
                HStack {
                    Image(systemName: merchant.icon)
                        .foregroundColor(.green)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(merchant.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(merchant.category)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private var transactionHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
            
            ForEach(walletViewModel.recentTransactions.prefix(3), id: \.id) { transaction in
                HStack {
                    Circle()
                        .fill(transaction.status == .approved ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(transaction.merchant)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(transaction.category)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(transaction.amount, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(transaction.status == .approved ? "Approved" : "Blocked")
                            .font(.caption)
                            .foregroundColor(transaction.status == .approved ? .green : .red)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
    
    private var addMerchantSheet: some View {
        NavigationStack {
            Form {
                Section("Merchant Details") {
                    TextField("Merchant Name", text: $newMerchantName)
                    
                    Picker("Category", selection: $newMerchantCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section("Attestation") {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Will be verified on-chain")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Add Merchant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingAddMerchant = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addMerchant()
                        showingAddMerchant = false
                    }
                    .disabled(newMerchantName.isEmpty)
                }
            }
        }
    }
    
    private func sendAllowance() async {
        // In production, this would create an ASA transfer transaction
        print("Sending weekly allowance of \(allowanceAmount) ALGO")
        
        // Mock the allowance transfer for demo
        await MainActor.run {
            walletViewModel.asaBalance += Double(allowanceAmount) ?? 50.0
        }
    }
    
    private func addMerchant() {
        // In production, this would create an on-chain attestation
        print("Adding merchant attestation: \(newMerchantName) - \(newMerchantCategory)")
        newMerchantName = ""
        newMerchantCategory = "Shopping"
    }
}

#Preview {
    ParentControlView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}