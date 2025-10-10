//
//  UserPreferences.swift
//  idle_01
//
//  Created by Adam Socki on 9/29/25.
//

import Foundation
import SwiftData

@Model
final class UserPreferences {
    // 0 = detailOnly, 1 = all (visible), 2 = automatic, 3 = doubleColumn (detail hidden)
    var simulatorColumnVisibilityRawValue: Int

    init(simulatorColumnVisibilityRawValue: Int = 3) {
        self.simulatorColumnVisibilityRawValue = simulatorColumnVisibilityRawValue
    }
}
