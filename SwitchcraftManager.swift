//
//  SwitchcraftManager.swift
//  Pods-Switchcraft_Example
//
//  Created by Brendan Lensink on 2018-03-29.
//

import Foundation

public class SwitchcraftManager {

    /**
     * Private shortcut to UserDefaults
     */
    private let defaults = UserDefaults.standard

    /**
     * Use the default global SwitchcraftManager Instance
     */
    public static let shared = SwitchcraftManager()

    /**
     * Create a new SwitchcraftManager instance
     */
    public init() {}

    /**
     * The currently selected endpoint
     */
    public var endpoint: String? {
        // TODO: Consider adding a private get/setter for userdefaults
        //         and store the value so we don't need to keep hitting defaults
        get {
            return UserDefaults.standard.string(forKey: defaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultsKey)
        }
    }

    /**
     * The location in UserDefaults.standard where the endpoint is stored.
     * Default is "switchcraftEndpoint"
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
    public var textFieldDoneTitle = "Done"

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
}
