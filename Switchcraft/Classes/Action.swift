//
//  Actions.swift
//  Pods-Switchcraft_Example
//
//  Created by Jake on 2018-07-05.
//

import Foundation

/**
 * Represents an action that can be tapped using the `Switchcraft` picker.
 */
public struct Action: Codable {
    /**
     * A title to be shown for the action.
     */
    public let title: String

    /**
     * A unique ID for the action.
     */
    public let actionId: String

    /**
     * Create a new action.
     *
     * - parameter title: The title to show in the endpoint selection menu.
     * - parameter actionId: The unique identifier for the action.
     */
    public init(title: String, actionId: String) {
        self.title = title
        self.actionId = actionId
    }
}

extension Action: Equatable {
    /**
     * Check equality between two Action.
     */
    public static func == (lhs: Action, rhs: Action) -> Bool {
        return lhs.actionId == rhs.actionId
    }
}
