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
    public let url: String

    /// The title will be displayed with this style. Default is .default.
    public let style: UIAlertActionStyle

    /**
     * Create a new endpoint.
     *
     * - parameter title: An optional title to show instead of the url when selecting an endpoint.
     * - parameter url: The url to save and return when chosen
     * - parameter style: The style of cell to display in the UIAlertController.
     */
    public init(title: String?, url: String, style: UIAlertActionStyle = . default) {
        self.title = title
        self.url = url
        self.style = style
    }
}

extension Endpoint: Equatable {
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        return lhs.title == rhs.title &&
            lhs.url == rhs.url
    }
}
