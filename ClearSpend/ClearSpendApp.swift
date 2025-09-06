import SwiftUI

@main
struct ClearSpendApp: App {
    @StateObject private var algorandService = AlgorandService()
    @StateObject private var walletViewModel = WalletViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(algorandService)
                .environmentObject(walletViewModel)
                .onAppear {
                    // Connect wallet service to Algorand service
                    walletViewModel.setAlgorandService(algorandService)
                }
        }
    }
}