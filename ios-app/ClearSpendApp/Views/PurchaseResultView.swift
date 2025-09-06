import SwiftUI

struct PurchaseResultView: View {
    let result: PurchaseResult
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Result Icon
                ZStack {
                    Circle()
                        .fill(result.success ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(result.success ? .green : .red)
                }
                
                // Result Message
                VStack(spacing: 8) {
                    Text(result.success ? "Purchase Approved!" : "Purchase Denied")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(result.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Transaction Details
                if result.success, let txId = result.transactionId {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Transaction ID")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(String(txId.prefix(20)) + "...")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                        
                        HStack {
                            Label("Verified on Algorand", systemImage: "checkmark.shield.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Spacer()
                            
                            Text(Date(), style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if let explorerLink = result.explorerLink {
                        Button(action: {
                            if let url = URL(string: explorerLink) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label("View on Algorand Explorer", systemImage: "safari")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: { dismiss() }) {
                        Text(result.success ? "Make Another Purchase" : "Try Again")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Transaction Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PurchaseResultView(result: PurchaseResult(
        success: true,
        message: "Your purchase has been verified and approved!",
        transactionId: "ABC123DEF456",
        explorerLink: "https://testnet.algoexplorer.io/tx/ABC123DEF456"
    ))
}