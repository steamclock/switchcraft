//
//  Endpoint.swift
//  Switchcraft
//
//  Created by Brendan Lensink on 2018-04-04.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

/**
 * Represents an endpoint that can be chosen using the `Switchcraft` picker.
 */
public struct Endpoint: Codable {

    /**
     * A title to be shown instead of the url in the UIAlertController.
     */
    public let title: String?

    /**
     * The URL associated with the endpoint.
     */
    public let url: URL

    /**
     * Helper variable to show a formatted user-facing name for the endpoint.
     */
    public var name: String {
        // If there's a user set title just return that
        if let title = title {
            return title
        }

        // Otherwise, clean up the url and return that
        return url.absoluteString.replacingOccurrences(of: "https://|http://", with: "", options: .regularExpression)
    }

    /**
     * Create a new endpoint.
     *
     * - parameter title: An optional title to show instead of the url when selecting an endpoint.
     * - parameter url: The url to save and return when chosen.
     */
    public init(title: String?, url: URL) {
        self.title = title
        self.url = url
    }
}

extension Endpoint: Equatable {
    /**
     * Check equality between two Endpoints.
     */
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        return lhs.title == rhs.title &&
            lhs.url == rhs.url
    }
}
