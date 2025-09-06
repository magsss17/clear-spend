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
    @State private var approvedMerchants: [ApprovedMerchant] = []
    @State private var isLoadingMerchants = false
    @State private var showingMerchantAlert = false
    @State private var merchantAlertMessage = ""
    
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
            .navigationTitle("Parent Controls")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddMerchant) {
                addMerchantSheet
            }
            .alert("Merchant Update", isPresented: $showingMerchantAlert) {
                Button("OK") { }
            } message: {
                Text(merchantAlertMessage)
            }
            .task {
                await loadMerchants()
            }
        }
    }
    
    private var parentDashboard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Teen's Allowance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(walletViewModel.formattedBalance) ALGO")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Weekly Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(allowanceAmount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            Divider()
            
            HStack {
                Label("Testnet Address", systemImage: "link")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let address = algorandService.currentAddress {
                    Text(String(address.prefix(8)) + "...")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
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
                        .foregroundColor(.secondary)
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
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
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
            
            if isLoadingMerchants {
                ProgressView("Loading merchants...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(approvedMerchants, id: \.id) { merchant in
                    merchantRow(merchant)
                }
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
                            .foregroundColor(.secondary)
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
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
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
                            .foregroundColor(.secondary)
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
    
    private func merchantRow(_ merchant: ApprovedMerchant) -> some View {
        HStack {
            Image(systemName: merchant.categoryIcon)
                .foregroundColor(merchant.parentApproved ? .green : .orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(merchant.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(merchant.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if merchant.dailyLimit > 0 {
                        Text("\(String(format: "%.1f", merchant.dailyUsagePercent))% used")
                            .font(.caption2)
                            .foregroundColor(merchant.dailyUsagePercent > 80 ? .red : .secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Button(action: {
                    Task {
                        await toggleParentApproval(merchant)
                    }
                }) {
                    Image(systemName: merchant.parentApproved ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(merchant.parentApproved ? .green : .red)
                }
                
                Text(merchant.parentApproved ? "Approved" : "Blocked")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func loadMerchants() async {
        isLoadingMerchants = true
        approvedMerchants = await algorandService.fetchMerchants()
        isLoadingMerchants = false
    }
    
    private func toggleParentApproval(_ merchant: ApprovedMerchant) async {
        let newApproval = !merchant.parentApproved
        let success = await algorandService.updateParentApproval(
            merchantName: merchant.name,
            approved: newApproval
        )
        
        if success {
            merchantAlertMessage = "\(merchant.name) has been \(newApproval ? "approved" : "blocked")"
            await loadMerchants() // Refresh the list
        } else {
            merchantAlertMessage = "Failed to update approval for \(merchant.name)"
        }
        
        showingMerchantAlert = true
    }
    
    private func addMerchant() {
        Task {
            let dailyLimitMicroAlgos = Int(Double(dailyLimit) ?? 50.0 * 1_000_000)
            let success = await algorandService.addMerchant(
                name: newMerchantName,
                category: newMerchantCategory,
                dailyLimit: dailyLimitMicroAlgos
            )
            
            if success {
                merchantAlertMessage = "\(newMerchantName) has been added successfully"
                
                // Add a small delay to ensure backend has processed the request
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                await loadMerchants() // Refresh the list
                newMerchantName = ""
                newMerchantCategory = "Shopping"
            } else {
                merchantAlertMessage = "Failed to add \(newMerchantName)"
            }
            
            showingMerchantAlert = true
        }
    }
}

#Preview {
    ParentControlView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}