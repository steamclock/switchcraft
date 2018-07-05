//
//  Actions.swift
//  Pods-Switchcraft_Example
//
//  Created by Jake on 2018-07-05.
//

import Foundation

/**
 * Represents an action that can be chosen using the `Switchcraft` picker.
 */
public struct Action {
    /**
     * A title to be shown for the action.
     */
    public let title: String

    /**
     * The callback for the action.
     */
    public let callback: () -> Void

    /**
     * Create a new action.
     *
     * - parameter title: The title to show in the endpoint selection menu.
     * - parameter callback: The callback to call when chosen.
     */
    public init(title: String, callback: @escaping () -> Void) {
        self.title = title
        self.callback = callback
    }
}

extension Action: Equatable {
    /**
     * Check equality between two Action.
     */
    public static func == (lhs: Action, rhs: Action) -> Bool {
        return lhs.title == rhs.title
    }
}
