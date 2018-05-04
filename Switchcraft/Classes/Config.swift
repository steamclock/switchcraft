//
//  Config.swift
//  Switchcraft
//
//  Created by Brendan Lensink on 2018-03-29.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import Foundation

/**
 * Handles config options for a Switchcraft instance.
 */
public struct Config {

    /**
     * The location in UserDefaults.standard where the endpoint is stored.
     * Default is "switchcraftEndpoint".
     */
    public var defaultsKey: String

    /**
     * The alert view title.
     * Default is "Select an Endpoint".
     */
    public var alertTitle = "Select an Endpoint"

    /**
     * The alert view message.
     * Default is `nil`.
     */
    public var alertMessage: String?

    /**
     * The alert view text field placeholder.
     * Default is "Enter Value".
     */
    public var textFieldPlaceholder = "Enter Value"

    /**
     * The alert view text field submit button.
     * Default is "Use Custom".
     */
    public var textFieldDoneTitle = "Use Custom"

    /**
     * The alert view cancel button title.
     * Default is "Cancel".
     */
    public var cancelTitle = "Cancel"

    /**
     * Whether the alert view will show a text field allowing custom entry.
     * Default is `false`.
     */
    public var allowCustom = false

    /**
     * The set of endpoints to be shown in the switcher.
     */
    public var endpoints: [Endpoint] = []

    /**
     * The index of the default endpoint in `endpoints`.
     * Default is `0`.
     * If this index is invalid for any reason it will default to the first endpoint.
     */
    public var defaultEndpointIndex: Int = 0

    /**
     * Determines if endpoint changes should be broadcast through `NotificationCenter`.
     * Default is `true`.
     */
    public var shouldBroadcastEndpointChange: Bool = true

    /**
     * The notification name to be used when an endpoint change is broadcast through `NotificationCenter`.
     */
    public let notificationName: Notification.Name = Notification.Name("switchcraftDidChangeEndpoint")

    /**
     * Create a new config with a set of endpoints and key.
     *
     * - parameter defaultsKey: The key to store the endpoint under in `UserDefaults`.
     * - parameter endpoints: The set of endpoints to show in the picker.
     * - parameter allowCustom: Whether the switcher allows entering custom endpoints.
     */
    public init(defaultsKey: String, endpoints: [Endpoint], allowCustom: Bool = false) {
        self.defaultsKey = defaultsKey
        self.endpoints = endpoints
        self.allowCustom = allowCustom
    }
}
