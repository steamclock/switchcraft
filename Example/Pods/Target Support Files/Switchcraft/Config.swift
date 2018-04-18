//
//  Config.swift
//  Pods-Switchcraft_Example
//
//  Created by Brendan Lensink on 2018-03-29.
//

import Foundation

/**
 * Handles config options for Switchcraft instances.
 * Must be passed into a new instance.
 */
public struct Config {

    /**
     * The location in UserDefaults.standard where the endpoint is stored.
     * Default is "switchcraftEndpoint".
     */
    public var defaultsKey = "switchcraftEndpoint"

    /**
     * The alert view title.
     * Default is "Select an Endpoint".
     */
    public var alertTitle = "Select an Endpoint"

    /**
     * The alert view message.
     * Default is nil.
     */
    public var alertMessage: String? = nil

    /**
     * The alert view text field placeholder.
     * Default is "Enter Value".
     */
    public var textFieldPlaceholder = "Enter Value"

    /**
     * The alert view text field submit button.
     * Default is "Done".
     */
    public var textFieldDoneTitle = "Use Custom"

    /**
     * The alert view cancel button title.
     * Default is "Cancel".
     */
    public var cancelTitle = "Cancel"

    /**
     * Whether the alert view will show a text field allowing custom entry.
     * Default is false.
     */
    public var allowCustom = false

    /**
     * The set of endpoints to be shown in the switcher.
     */
    public var endpoints: [Endpoint] = []

    /**
     * The index of the default endpoint in `endpoints`.
     * If this index is invalid for any reason it will default to the first endpoint.
     */
    public var defaultEndpointIndex: Int = 0

    /**
     * Create a new config with a set of endpoints.
     *
     * - parameter endpoints: The set of endpoints to show in the picker.
     */
    public init(endpoints: [Endpoint]) {
        self.endpoints = endpoints
    }
}