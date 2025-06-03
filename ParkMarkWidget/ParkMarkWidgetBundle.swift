//
//  ParkMarkWidgetBundle.swift
//  ParkMarkWidget
//
//  Created by Conor Giffen-McCloskey on 02/06/2025.
//

import WidgetKit
import SwiftUI


// 8) Bundle only Small + Medium
@main
struct ParkMarkWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        ParkMarkSmallWidget()
        ParkMarkMediumWidget()
    }
}

