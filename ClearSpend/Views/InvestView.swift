import SwiftUI

struct InvestView: View {
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
                    title: "Savings",
                    amount: "25 ALGO",
                    percentage: "+5.2%",
                    icon: "banknote",
                    color: .green
                )
                
                PortfolioCard(
                    title: "Locked",
                    amount: "100 ALGO",
                    percentage: "30 days",
                    icon: "lock.fill",
                    color: .blue
                )
            }
        }
    }
    
    private var investmentOptions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Investment Options")
                .font(.headline)
            
            ForEach(["High Yield Savings", "Teen Index Fund", "Crypto Basket"], id: \.self) { option in
                InvestmentOptionCard(
                    title: option,
                    description: getDescription(for: option),
                    apy: getAPY(for: option),
                    risk: getRisk(for: option)
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
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func getDescription(for option: String) -> String {
        switch option {
        case "High Yield Savings":
            return "Earn interest on your ALGO with low risk"
        case "Teen Index Fund":
            return "Diversified portfolio for young investors"
        case "Crypto Basket":
            return "Balanced mix of top cryptocurrencies"
        default:
            return ""
        }
    }
    
    private func getAPY(for option: String) -> String {
        switch option {
        case "High Yield Savings": return "3.5%"
        case "Teen Index Fund": return "8.2%"
        case "Crypto Basket": return "12.5%"
        default: return "0%"
        }
    }
    
    private func getRisk(for option: String) -> String {
        switch option {
        case "High Yield Savings": return "Low"
        case "Teen Index Fund": return "Medium"
        case "Crypto Basket": return "High"
        default: return "Unknown"
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
                    .foregroundColor(.secondary)
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
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(apy)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("APY")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Label(risk, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                    .foregroundColor(riskColor)
                
                Spacer()
                
                Button("Invest") {
                    // Investment action
                }
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    InvestView()
}