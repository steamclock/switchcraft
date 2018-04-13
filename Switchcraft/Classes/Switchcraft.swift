//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//
//

public class Switchcraft {
    // TODO: I'm not sure this is the best way to do this (with a setup()) you have to call to get the singleton going, but I'm not sure if there's another way :/
    public static let shared = Switchcraft()

    private init() {}

    // MARK: Private Declarations

    /**
     * Private shortcut to UserDefaults.
     */
    private let defaults = UserDefaults.standard

    /**
     * The action triggered by the tap gesture recognizer.
     */
    private var tapAction: (() -> Void)?

    private var textFieldDoneButton: UIAlertAction?

    // MARK: Public Declarations

    /**
     * User set configuration options. Must be set before using `Switchcraft`.
     */
    public var config: Config!

    /**
     * The currently selected endpoint.
     */
    public var endpoint: URL? {
        // TODO: Consider adding a private get/setter for userdefaults
        //         and store the value so we don't need to keep hitting defaults
        get {
            return UserDefaults.standard.url(forKey: config.defaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: config.defaultsKey)
        }
    }

    /**
     * Check if the current endpoint is the default one.
     */
    // TODO: this could be named better
    public var currentEndpointIsDefault: Bool {
        return endpoint == config.endpoints[config.defaultEndpointIndex].url
    }

    /**
     * Convenience function to get the default endpoint.
     */
    public var defaultEndpoint: Endpoint {
        get {
            return config.endpoints[config.defaultEndpointIndex]
        }
    }

    /**
     * Set up the Switchcraft manager for use later.
     *
     * - parameter config: The config options to use when managing the switcher.
     */
    public func setup(config: Config) {
        let endpoints = config.endpoints

        guard !endpoints.isEmpty else {
            fatalError("Switchcraft.setup called with no endpoints set. You probably didn't mean to do that.")
        }

        if !endpoints.indices.contains(config.defaultEndpointIndex) {
            debugPrint("`defaultEndpointIndex` was invalid, reverting to the first element")
            self.config.defaultEndpointIndex = 0
        }

        self.config = config

        // If there's no endpoint saved, store the default
        if endpoint == nil {
            endpoint = endpoints[config.defaultEndpointIndex].url
        }
    }

    /**
     * Attach the default gesture recognizer to a view controller to show the switcher within its view.
     *
     * - parameter to: The view controller to show the switcher in.
     */
    public func attachGesture(to viewController: UIViewController) {
        // TODO: Add possibility to pass in custom gesture here

        // Make sure the view is touchable
        viewController.view.isUserInteractionEnabled = true

        let defaultGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        defaultGesture.numberOfTapsRequired = 1 // 2
        defaultGesture.numberOfTouchesRequired = 1 // 3
        tapAction = { self.display(from: viewController) }

        viewController.view.addGestureRecognizer(defaultGesture)
    }

    /**
     * Attach the default gesture recognizer to a view, along with the view controller to show the switcher in.
     *
     * - parameter to: The view to attach the gesture recognizer to.
     * - parameter parent: The view controller to show the switcher in.
     */
    public func attachGesture(to view: UIView, parent: UIViewController) {
        view.isUserInteractionEnabled = true

        let defaultGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        defaultGesture.numberOfTapsRequired = 1 // 2
        defaultGesture.numberOfTouchesRequired = 1 // 3
        tapAction = { self.display(from: parent) }

        view.addGestureRecognizer(defaultGesture)
    }

    /**
     * Show the switcher within the given view controller
     *
     * - parameter from: The view controller to show the switcher in.
     */
    public func display(from parentVC: UIViewController) {

        let viewController = UIViewController()
        viewController.modalPresentationStyle = .overCurrentContext
        parentVC.present(viewController, animated: true, completion: nil)

        var alertTitle = config.alertTitle
        if let currentEndpoint = endpoint {
            // TODO: We probably want to change this to use the title instead of the url if possible
            alertTitle += "\nCurrent Endpoint: \(currentEndpoint)"
        }

        let alertController = UIAlertController(
            title: alertTitle,
            message: config.alertMessage,
            preferredStyle: config.allowCustom ? .alert : .actionSheet
        )

        if config.allowCustom {
            textFieldDoneButton = UIAlertAction(
                title: config.textFieldDoneTitle,
                style: .default,
                handler: { _ in
                    viewController.dismiss(animated: false, completion: nil)

                    guard let textField = alertController.textFields?.first, var text = textField.text else {
                        return
                    }

                    if !text.contains("http://") && !text.contains("https://") {
                     text = "http://" + text
                    }

                    guard let url = URL(string: text) else {
                        return
                    }
                    self.endpoint = url
                }
            )
            alertController.addAction(textFieldDoneButton!)

            alertController.addTextField (configurationHandler: { textField in
                textField.placeholder = self.config.textFieldPlaceholder
                textField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                textField.text = self.endpoint?.absoluteString
            })
        }

        for endpoint in config.endpoints {
            // Don't show the currently selected endpoint as an option
            // TODO: I suspect this will be confusing and need to be changed.
            guard endpoint.url != self.endpoint else { continue }

            alertController.addAction(
                // TODO: Better default value for title, can atleast strip http, etc
                UIAlertAction(
                    title: endpoint.title ?? endpoint.url.absoluteString,
                    style: .default,
                    handler: { [weak self] (action) in
                        self?.endpoint = endpoint.url
                        viewController.dismiss(animated: false, completion: nil)
                    }
                )
            )
        }

        alertController.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: { _ in viewController.dismiss(animated: false, completion: nil) }))

        viewController.present(alertController, animated: true, completion: nil)
    }

    // MARK: Private Helpers

    @objc private func tapHandler(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }

    @objc private func textFieldChanged(_ sender: UITextField) {
        guard var text = sender.text else {
            textFieldDoneButton?.isEnabled = false
            return
        }

        if !text.contains("http://") && !text.contains("https://") {
            text = "http://" + text
        }

        self.textFieldDoneButton?.isEnabled = canOpenURL(text)
    }

    private func canOpenURL(_ string: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/36012850/6718381
        guard let url = URL(string: string), UIApplication.shared.canOpenURL(url) else {
            return false
        }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[regEx])
        return predicate.evaluate(with: string)
    }
}
