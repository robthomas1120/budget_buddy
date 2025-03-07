import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of one entry
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct BudgetBuddyWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            Text("Budget Buddy")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack(spacing: 10) {
                Link(destination: URL(string: "budgetbuddy://addIncome")!) {
                    VStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                        Text("Income")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Link(destination: URL(string: "budgetbuddy://addExpense")!) {
                    VStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red)
                        Text("Expense")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
    }
}

@main
struct BudgetBuddyWidget: Widget {
    let kind: String = "BudgetBuddyWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            BudgetBuddyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Transaction")
        .description("Quickly add income or expenses without opening the app.")
        .supportedFamilies([.systemSmall])
    }
}

struct BudgetBuddyWidget_Previews: PreviewProvider {
    static var previews: some View {
        BudgetBuddyWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
