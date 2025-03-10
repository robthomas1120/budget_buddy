//
//  BudgetBuddyWidgetLiveActivity.swift
//  BudgetBuddyWidget
//
//  Created by Rob Thomas Alvarez on 3/7/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BudgetBuddyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BudgetBuddyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BudgetBuddyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BudgetBuddyWidgetAttributes {
    fileprivate static var preview: BudgetBuddyWidgetAttributes {
        BudgetBuddyWidgetAttributes(name: "World")
    }
}

extension BudgetBuddyWidgetAttributes.ContentState {
    fileprivate static var smiley: BudgetBuddyWidgetAttributes.ContentState {
        BudgetBuddyWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BudgetBuddyWidgetAttributes.ContentState {
         BudgetBuddyWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BudgetBuddyWidgetAttributes.preview) {
   BudgetBuddyWidgetLiveActivity()
} contentStates: {
    BudgetBuddyWidgetAttributes.ContentState.smiley
    BudgetBuddyWidgetAttributes.ContentState.starEyes
}
