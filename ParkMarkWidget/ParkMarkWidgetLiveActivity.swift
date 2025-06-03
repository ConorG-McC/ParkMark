//
//  ParkMarkWidgetLiveActivity.swift
//  ParkMarkWidget
//
//  Created by Conor Giffen-McCloskey on 02/06/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ParkMarkWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ParkMarkWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ParkMarkWidgetAttributes.self) { context in
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

extension ParkMarkWidgetAttributes {
    fileprivate static var preview: ParkMarkWidgetAttributes {
        ParkMarkWidgetAttributes(name: "World")
    }
}

extension ParkMarkWidgetAttributes.ContentState {
    fileprivate static var smiley: ParkMarkWidgetAttributes.ContentState {
        ParkMarkWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ParkMarkWidgetAttributes.ContentState {
         ParkMarkWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ParkMarkWidgetAttributes.preview) {
   ParkMarkWidgetLiveActivity()
} contentStates: {
    ParkMarkWidgetAttributes.ContentState.smiley
    ParkMarkWidgetAttributes.ContentState.starEyes
}
