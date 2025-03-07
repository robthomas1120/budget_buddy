//
//  BudgetBuddyWidgetBundle.swift
//  BudgetBuddyWidget
//
//  Created by Rob Thomas Alvarez on 3/7/25.
//

import WidgetKit
import SwiftUI

@main
struct BudgetBuddyWidgetBundle: WidgetBundle {
    var body: some Widget {
        BudgetBuddyWidget()
        BudgetBuddyWidgetControl()
        BudgetBuddyWidgetLiveActivity()
    }
}
