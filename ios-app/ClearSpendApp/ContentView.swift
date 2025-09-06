import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showingParentMode = false
    
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
            
            ParentControlView()
                .tabItem {
                    Label("Parent", systemImage: "person.2.fill")
                }
                .tag(4)
        }
        .tint(.purple)
        .background(Color.white)
        .onAppear {
            // Configure tab bar appearance for white theme
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithOpaqueBackground()
            tabAppearance.backgroundColor = UIColor.white
            tabAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            
            // Configure navigation bar for white theme
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = UIColor.white
            navAppearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            navAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
            
            // Configure list appearance for white theme
            UITableView.appearance().backgroundColor = UIColor.white
            UITableView.appearance().separatorColor = UIColor.gray.withAlphaComponent(0.2)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AlgorandService())
        .environmentObject(WalletViewModel())
}