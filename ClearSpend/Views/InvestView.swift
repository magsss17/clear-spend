import SwiftUI

struct InvestView: View {
    @EnvironmentObject var walletViewModel: WalletViewModel
    @State private var selectedInvestmentType = "Savings"
    let investmentTypes = ["Savings", "Stocks", "Crypto", "Education Fund"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    portfolioOverview
                    
                    investmentOptions
                    
                    learningResources
                }
                .padding()
            }
            .navigationTitle("Invest")
        }
    }
    
    private var portfolioOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Portfolio")
                .font(.headline)
            
            HStack(spacing: 16) {
                PortfolioCard(
                    title: "Balance",
                    amount: "\(walletViewModel.formattedBalance) ALGO",
                    percentage: "+5.2%",
                    icon: "banknote",
                    color: .green
                )
                
                PortfolioCard(
                    title: "Profits",
                    amount: "100 ALGO",
                    percentage: "30 days",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
            }
        }
    }
    
    private var investmentOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Investment Options")
                .font(.headline)
            
            ForEach(["Real Estate (Lofty)", "Liquid Staking (xAlgo)", "P2P Staking (Valar)"], id: \.self) { option in
                InvestmentOptionCard(
                    title: option,
                    description: getDescription(for: option),
                    apy: getAPY(for: option),
                    risk: getRisk(for: option),
                    learnURL: getLearnURL(for: option)
                )
            }
        }
    }
    
    private var learningResources: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learn More")
                .font(.headline)
            
            HStack {
                Image(systemName: "book.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.purple)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Investment Basics")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Start your investment journey")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func getDescription(for option: String) -> String {
        switch option {
        case "Real Estate (Lofty)":
            return "Invest in real estate through fractional ownership"
        case "Liquid Staking (xAlgo)":
            return "Stake ALGO and earn rewards while maintaining liquidity"
        case "P2P Staking (Valar)":
            return "Peer-to-peer staking with competitive rates"
        default:
            return ""
        }
    }
    
    private func getAPY(for option: String) -> String {
        switch option {
        case "Real Estate (Lofty)": return "8-12%"
        case "Liquid Staking (xAlgo)": return "5.51%"
        case "P2P Staking (Valar)": return "5.17%"
        default: return "0%"
        }
    }
    
    private func getRisk(for option: String) -> String {
        switch option {
        case "Real Estate (Lofty)": return "Medium"
        case "Liquid Staking (xAlgo)": return "Low"
        case "P2P Staking (Valar)": return "Low"
        default: return "Unknown"
        }
    }
    
    private func getLearnURL(for option: String) -> String {
        switch option {
        case "Real Estate (Lofty)": return "https://www.lofty.ai/"
        case "Liquid Staking (xAlgo)": return "https://algorand.co/staking-rewards"
        case "P2P Staking (Valar)": return "https://stake.valar.solutions/"
        default: return ""
        }
    }
}

struct PortfolioCard: View {
    let title: String
    let amount: String
    let percentage: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(amount)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(percentage)
                .font(.caption)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct InvestmentOptionCard: View {
    let title: String
    let description: String
    let apy: String
    let risk: String
    let learnURL: String
    @EnvironmentObject var walletViewModel: WalletViewModel
    
    var riskColor: Color {
        switch risk {
        case "Low": return .green
        case "Medium": return .orange
        case "High": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(apy)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("APY")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Label(risk, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(riskColor)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("Learn") {
                        if let url = URL(string: learnURL) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
                    Button("Invest") {
                        // Subtract $25 from balance
                        walletViewModel.subtractFromBalance(25.0)
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    InvestView()
        .environmentObject(WalletViewModel())
}