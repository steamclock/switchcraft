//
//  \Endpoint.swift
//  Pods-Switchcraft_Example
//
//  Created by Brendan Lensink on 2018-04-04.
//

/**
 * Represents an endpoint that can be chosen using the `Switchcraft` picker
 */
public struct Endpoint {

    /// A title that will be shown instead of the url in the UIAlertController. Defaults to the url
    public let title: String?

    /// The URL associated with the endpoint.
    public let url: URL

    /**
     * Create a new endpoint.
     *
     * - parameter title: An optional title to show instead of the url when selecting an endpoint.
     * - parameter url: The url to save and return when chosen
     */
    public init(title: String?, url: URL) {
        self.title = title
        self.url = url
    }
}

extension Endpoint: Equatable {
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        return lhs.title == rhs.title &&
            lhs.url == rhs.url
    }
}
