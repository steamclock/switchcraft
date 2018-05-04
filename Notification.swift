//
//  Notification.swift
//  Alamofire
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
     * Posted when the chosen endpoint is changed.
     * The notification `object` contains a reference to the `Switchcraft` instance that sent it.
     * The `UserInfo` dictionary contains an Endpoint accessed with the key `endpointDidChangeUserInfoKey`.
     */
    public static let SwitchCraftDidChangeEndpoint = Notification.Name("switchCraftDidChangeEndpoint")

}
