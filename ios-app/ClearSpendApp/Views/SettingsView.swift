import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var algorandService: AlgorandService
    @State private var notificationsEnabled = true
    @State private var biometricsEnabled = true
    @State private var showingWalletDetails = false
    
    var body: some View {
        NavigationStack {
            List {
                walletSection
                
                securitySection
                
                preferencesSection
                
                aboutSection
            }
            .navigationTitle("Settings")
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
    
    private var walletSection: some View {
        Section("Wallet") {
            HStack {
                Label("Wallet Address", systemImage: "wallet.pass")
                
                Spacer()
                
                if let address = algorandService.currentAddress {
                    Text(String(address.prefix(8)) + "...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospaced()
                }
            }
            
            Button(action: { showingWalletDetails = true }) {
                Label("View Wallet Details", systemImage: "eye")
                    .foregroundColor(.purple)
            }
            
            HStack {
                Label("Network", systemImage: "network")
                
                Spacer()
                
                Text("Algorand Testnet")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var securitySection: some View {
        Section("Security") {
            Toggle(isOn: $biometricsEnabled) {
                Label("Face ID", systemImage: "faceid")
            }
            
            Toggle(isOn: $notificationsEnabled) {
                Label("Transaction Notifications", systemImage: "bell")
            }
            
            Button(action: {}) {
                Label("Change PIN", systemImage: "lock.rotation")
                    .foregroundColor(.purple)
            }
        }
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            HStack {
                Label("Currency", systemImage: "dollarsign.circle")
                
                Spacer()
                
                Text("ALGO")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Language", systemImage: "globe")
                
                Spacer()
                
                Text("English")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Theme", systemImage: "paintbrush")
                
                Spacer()
                
                Text("System")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                
                Spacer()
                
                Text("1.0.0 (Hackathon Demo)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                if let url = URL(string: "https://algorand.foundation") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Learn About Algorand", systemImage: "safari")
                    .foregroundColor(.purple)
            }
            
            Button(action: {}) {
                Label("Terms & Privacy", systemImage: "doc.text")
                    .foregroundColor(.purple)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AlgorandService())
}