import SwiftUI

struct LearnView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Budgeting", "Saving", "Investing", "Credit", "Crypto"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    progressCard
                    
                    categoryFilter
                    
                    featuredContent
                    
                    learningModules
                }
                .padding()
            }
            .navigationTitle("Learn")
            .searchable(text: $searchText, prompt: "Search topics")
        }
    }
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Learning Journey")
                        .font(.headline)
                    
                    Text("Level 3 - Smart Spender")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "trophy.fill")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
            }
            
            ProgressView(value: 0.65)
                .tint(.purple)
            
            HStack {
                Text("325 XP")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("175 XP to Level 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryPill(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var featuredContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured")
                .font(.headline)
            
            FeaturedCard(
                title: "Understanding Blockchain",
                description: "Learn how Algorand powers secure transactions",
                duration: "15 min",
                xp: 50,
                icon: "cube.transparent"
            )
        }
    }
    
    private var learningModules: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Paths")
                .font(.headline)
            
            ForEach(LearningModule.examples) { module in
                LearningModuleCard(module: module)
            }
        }
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct FeaturedCard: View {
    let title: String
    let description: String
    let duration: String
    let xp: Int
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.purple)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Label("\(xp) XP", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(duration)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {}) {
                Text("Start Learning")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.05), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct LearningModuleCard: View {
    let module: LearningModule
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: module.icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 50, height: 50)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(module.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(module.lessons) lessons • \(module.duration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: module.progress)
                    .tint(.purple)
            }
            
            Spacer()
            
            if module.progress == 1.0 {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Text("\(Int(module.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    LearnView()
}