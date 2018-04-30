//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

/**
 * Protocol allowing conforming objects to monitor changes to the selected endpoint.
 */
public protocol SwitchcraftDelegate: AnyObject {

    /**
     * Called whenever the selected endpoint changes.
     */
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpointTo newEndpoint: Endpoint)
}

/**
 * Global instance used to coordinate endpoint selection and retrieval.
 * Tracks current endpoint selection, along with config options.
 */
public class Switchcraft {

    /**
     * Singleton instance.
     */
    public static let shared = Switchcraft()

    /**
     * Enforce singleton behaviour.
     */
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

    /**
     * A reference the the action sheet text field submit button.
     * Needed to toggle enabled for the button as text is entered.
     */
    private var textFieldDoneButton: UIAlertAction?

    /**
     * User set configuration options. Must be set before using `Switchcraft`.
     */
    private var config: Config!

    // MARK: Public Declarations

    /**
     * Delegate to receive updates for changes to the endpoint
     */
    public weak var delegate: SwitchcraftDelegate?

    /**
     * The currently selected endpoint.
     */
    public var endpoint: Endpoint? {
        get {
            if let data = UserDefaults.standard.data(forKey: config.defaultsKey),
                    let endpoint = try? JSONDecoder().decode(Endpoint.self, from: data) {
                return endpoint
            }
            return nil
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: config.defaultsKey)
            }
        }
    }

    /**
     * Check if the current endpoint is the default one.
     */
    public var isDefaultEndpoint: Bool {
        return endpoint == config.endpoints[config.defaultEndpointIndex]
    }

    /**
     * Convenience function to get the default endpoint.
     */
    public var defaultEndpoint: Endpoint {
        return config.endpoints[config.defaultEndpointIndex]
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
            debugPrint("`defaultEndpointIndex` was invalid, reverting to the first element.")
            self.config.defaultEndpointIndex = 0
        }

        self.config = config

        // If there's no endpoint saved, store the default
        if endpoint == nil {
            selected(endpoint: endpoints[config.defaultEndpointIndex])
        }
    }

    /**
     * Attach the default gesture recognizer to a view, along with the view controller to show the switcher in.
     *
     * - parameter to: The view to attach the gesture recognizer to.
     * - parameter parent: The view controller to show the switcher in.
     */
    public func attachGesture(to parent: UIViewController, gestureView: UIView? = nil, gestureRecognizer: UITapGestureRecognizer? = nil) {
        guard let view = gestureView ?? parent.view else {
            fatalError("Failed to attach a gesture recognizer, parent's view was `nil`")
        }

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer ?? makeDefaultGestureRecognizer(forVC: parent))

        // Notify the parent of the current selected endpoint after attaching to it
        if let currentEndpoint = endpoint {
            delegate?.switchcraft(self, didChangeEndpointTo: currentEndpoint)
        }
    }

    /**
     * Show the switcher within the given view controller.
     *
     * - parameter from: The view controller to show the switcher in.
     */
    public func display(from parentVC: UIViewController) {
        let viewController = UIViewController()
        viewController.modalPresentationStyle = .overCurrentContext
        parentVC.present(viewController, animated: true, completion: nil)

        var alertTitle = config.alertTitle
        if let currentEndpoint = endpoint {
            alertTitle += "\nCurrent Endpoint: \(currentEndpoint.name)"
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
                    self.selected(endpoint: Endpoint(title: "Custom URL", url: url))
                }
            )
            alertController.addAction(textFieldDoneButton!)

            alertController.addTextField (configurationHandler: { textField in
                textField.placeholder = self.config.textFieldPlaceholder
                textField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                textField.text = self.endpoint?.url.absoluteString
            })
        }

        for endpoint in config.endpoints {
            // Don't show the currently selected endpoint as an option
            guard endpoint != self.endpoint else { continue }

            alertController.addAction(
                UIAlertAction(
                    title: endpoint.name,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.selected(endpoint: endpoint)
                        viewController.dismiss(animated: false, completion: nil)
                    }
                )
            )
        }

        alertController.addAction(
            UIAlertAction(
                title: config.cancelTitle,
                style: .cancel,
                handler: { _ in viewController.dismiss(animated: false, completion: nil) }
            )
        )

        viewController.present(alertController, animated: true, completion: nil)
    }

    // MARK: Private Actions And Helpers

    /**
     * Called by the gesture recognizer when it is triggered.
     *
     * - parameter sender: A reference to the `UITapGestureRecognizer` that send the event.
     */
    @objc private func tapHandler(_ sender: UITapGestureRecognizer) {
        tapAction?()
    }

    /**
     * Text field event listener, updates the done button as the text field is modified.
     *
     * - parameter sender: A reference to the text field.
     */
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

    /**
     * Checks if a given string is a valid url and can be opened.
     *
     * - parameter string: The string to check
     *
     * - returns: True if the string is a well formed URL, false if not.
     */
    private func canOpenURL(_ string: String) -> Bool {
        // Adapted from https://stackoverflow.com/a/36012850/6718381
        guard let url = URL(string: string), UIApplication.shared.canOpenURL(url) else {
            return false
        }

        let regEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: string)
    }

    /**
     * Called when a new endpoint is selected, propogate to the delegate and store the new endpoint.
     *
     * - parameter endpoint: The new endpoint to save.
     */
    private func selected(endpoint: Endpoint) {
        self.endpoint = endpoint
        delegate?.switchcraft(self, didChangeEndpointTo: endpoint)
        if config.shouldBroadcastEndpointChange {
            NotificationCenter.default.post(name: config.broadcastName, object: endpoint)
        }
    }

    /**
     * Create and return the default gesture recognizer to attack to a view.
     *
     * - parameter viewController: The view controller the switcher will be attached to when displayed.
     *
     * - returns: The new gesture recognizer.
     */
    private func makeDefaultGestureRecognizer(forVC viewController: UIViewController) -> UITapGestureRecognizer {
        tapAction = { self.display(from: viewController) }

        let defaultGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        defaultGesture.numberOfTapsRequired = 2
        defaultGesture.numberOfTouchesRequired = 3
        return defaultGesture
    }
}
