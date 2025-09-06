import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var algorandService: AlgorandService
    @State private var notificationsEnabled = true
    @State private var biometricsEnabled = true
    
    var body: some View {
        NavigationStack {
            List {
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
                    
                    HStack {
                        Label("Network", systemImage: "network")
                        
                        Spacer()
                        
                        Text("Algorand Testnet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Security") {
                    Toggle(isOn: $biometricsEnabled) {
                        Label("Face ID", systemImage: "faceid")
                    }
                    
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Transaction Notifications", systemImage: "bell")
                    }
                }
                
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
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.white)
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
        .background(Color.white)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AlgorandService())
}