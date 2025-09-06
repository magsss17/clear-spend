import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SpendView()
                .tabItem {
                    Label("Spend", systemImage: "creditcard.fill")
                }
                .tag(1)
            
            InvestView()
                .tabItem {
                    Label("Invest", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
            
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(3)
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}