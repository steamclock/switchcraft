//
//  Notification.swift
//  Switchcraft
//
//  Created by Brendan Lensink on 2018-05-04.
//

import Foundation

extension Notification {
    /**
     * Namespace for public notification keys.
     */
    public struct Key {
        /**
         * User info dictionary key containing the new `Endpoint`.
         */
        public static let Endpoint = "switchcraftEndpoint"
    }
}

extension Notification.Name {
    /**
     * Posted when an `Endpoint` is selected.
     * The notification `object` contains a reference to the `Switchcraft` instance that sent it.
     * The `UserInfo` dictionary contains an Endpoint accessed with the key `Notification.Key.Endpoint`
     */
    public static let SwitchcraftDidSelectEndpoint = Notification.Name("switchcraftDidSelectEndpoint")
}
