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
     * Default is the current build name and version number.
     */
    public var alertMessage: String? {
        guard let bundle = Bundle.main.infoDictionary,
            let displayName = (bundle["CFBundleDisplayName"] as? String) ?? (bundle["CFBundleName"] as? String),
            let versionString = bundle["CFBundleShortVersionString"] as? String,
            let buildNumber = bundle["CFBundleVersion"] as? String else {
                return nil
        }

        return displayName + " " + versionString + "-" + buildNumber
    }
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
     * The set of custom actions to be shown in the switcher.
     */
    public var actions: [Action] = []

    /**
     * The index of the default endpoint in `endpoints`.
     * Default is `0`.
     * If this index is invalid for any reason it will default to the first endpoint.
     */
    public var defaultEndpointIndex: Int = 0

    /**
     * Show an alert if the app requires a restart before the endpoint change will take effect.
     * If set to true, after changing endpoints there will be an alert presented with an option to force quit the app to restart.
     * Default is `false`.
     */
    public var changeRequiresRestart: Bool = false

    /**
     * Create a new config with a set of endpoints and key.
     *
     * - parameter defaultsKey: The key to store the endpoint under in `UserDefaults`.
     * - parameter endpoints: The set of endpoints to show in the picker.
     * - parameter allowCustom: Whether the switcher allows entering custom endpoints.
     */
    public init(defaultsKey: String, endpoints: [Endpoint], actions: [Action] = [], allowCustom: Bool = false) {
        self.defaultsKey = defaultsKey
        self.endpoints = endpoints
        self.allowCustom = allowCustom
        self.actions = actions
    }
}
