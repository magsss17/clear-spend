import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var statusColor: Color {
        switch transaction.status {
        case .approved: return .green
        case .rejected: return .red
        case .pending: return .orange
        case .requiresParentApproval: return .blue
        }
    }
    
    var categoryIcon: String {
        switch transaction.category {
        case "Shopping": return "bag.fill"
        case "Food": return "fork.knife"
        case "Entertainment": return "tv.fill"
        case "Education": return "book.fill"
        case "Transportation": return "car.fill"
        case "Gaming": return "gamecontroller.fill"
        case "Investment": return "chart.line.uptrend.xyaxis"
        case "Charity": return "heart.fill"
        default: return "tag.fill"
        }
    }
    
    var body: some View {
        Button(action: {
            if let explorerLink = transaction.explorerLink {
                if let url = URL(string: explorerLink) {
                    UIApplication.shared.open(url)
                }
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(transaction.category == "Investment" ? .green : .purple)
                    .frame(width: 40, height: 40)
                    .background((transaction.category == "Investment" ? Color.green : Color.purple).opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.merchant)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(transaction.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(transaction.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("-\(transaction.formattedAmount)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(transaction.status == .rejected ? .secondary : .primary)
                    
                    Text(transaction.status.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(10)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 8)
    }
}