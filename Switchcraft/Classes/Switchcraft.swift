//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

/**
 * Protocol allowing conforming objects to monitor endpoint selection.
 */
public protocol SwitchcraftDelegate: AnyObject {
    /**
     * Called when an endpoint is selected.
     */
    func switchcraft(_ switchcraft: Switchcraft, didSelectEndpoint endpoint: Endpoint)
}

/**
 * Switchcraft is a simple manager to make switching endpoints easier.
 *
 * If you only plan on using a single instance of Switchcraft, we recommend following the ReallySimpleVC example.
 * In your `AppDelegate.swift`, create a global extension as follows:
 *     extension Switchcraft {
 *        static let shared = Switchcraft(config: /*..*/)
 *    }
 * You can then get the current from anywhere as `Switchcraft.shared.endpoint`.
 */
public class Switchcraft {

    // MARK: - Initializers

    /**
     * Create a new Switchcraft instance with the provided config.
     *
     * - parameter config: The configuration to use when setting up a new instance.
     */
    public init(config: Config) {
        guard !config.endpoints.isEmpty else {
            fatalError("Switchcraft.setup called with no endpoints set. You probably didn't mean to do that.")
        }

        self.config = config

        let endpoints = config.endpoints
        if !endpoints.indices.contains(config.defaultEndpointIndex) {
            debugPrint("`defaultEndpointIndex` was invalid, reverting to the first endpoint. ")
            self.config.defaultEndpointIndex = 0
        }

        // If there's no endpoint stored, store the default one
        if endpoint == nil {
            selected(endpoint: endpoints[config.defaultEndpointIndex])
        }
    }

    // MARK: - Private Declarations

    /**
     * User defined configuration options.
     */
    private var config: Config

    /**
     * Convenience shortcut to UserDefaults.
     */
    private let defaults = UserDefaults.standard

    /**
     * The action triggered by the tap gesture recognizer when pressed.
     */
    private var showSwitcher: (() -> Void)?

    /**
     * A reference to the action sheet text field submit button.
     * Needed to toggle enabled for the button as text is entered.
     */
    private var textFieldDoneButton: UIAlertAction?

    // MARK: - Public Declarations

    /**
     * Delegate to receive updates for endpoint selection.
     */
    public weak var delegate: SwitchcraftDelegate?

    /**
     * The currently selected endpoint.
     */
    public private(set) var endpoint: Endpoint? {
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
     * Link the Switchcraft instance with a view controller for presentation
     * Optionally, provide a custom view and gesture recognizer to handle showing the switcher.
     *
     * - parameter parent: The view controller to show the switcher in.
     * - parameter gestureView: An optional view to attach the switcher's gesture recognizer to.
     * - parameter gestureRecognizer: An optional custom gesture recognizer to show the switcher.
     */
    public func attachGesture(to parent: UIViewController, gestureView: UIView? = nil, gestureRecognizer: UITapGestureRecognizer? = nil) {
        guard let view = gestureView ?? parent.view else {
            fatalError("Called `attachGesture` without a valid view. `parent`'s view is probably nil.")
        }

        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer ?? makeDefaultGestureRecognizer(forVC: parent))

        // Notify the delegate of the current endpoint after attaching to it.
        if let currentEndpoint = endpoint {
            selected(endpoint: currentEndpoint)
        }
    }

    /**
     * Show the switcher within the given view controller.
     *
     * - parameter parentVC: The view controller to show the switcher in.
     */
    public func display(from parentVC: UIViewController) {
        let viewController = UIViewController()
        viewController.modalPresentationStyle = .overCurrentContext
        parentVC.present(viewController, animated: true, completion: nil)

        let alertController = UIAlertController(
            title: config.alertTitle,
            message: config.alertMessage,
            preferredStyle: config.allowCustom ? .alert : .actionSheet
        )

        for endpoint in config.endpoints {
            alertController.addAction(
                UIAlertAction(
                    title: endpoint.name + (endpoint == self.endpoint ? " ✔ " : ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.selected(endpoint: endpoint)
                        viewController.dismiss(animated: false, completion: nil)
                    }
                )
            )
        }

        if config.allowCustom {
            textFieldDoneButton = UIAlertAction(
                title: config.textFieldDoneTitle,
                style: .default,
                handler: { _ in
                    guard let textField = alertController.textFields?.first,
                            let text = textField.text,
                            let url = URL(string: text) else {
                        return
                    }

                    viewController.dismiss(animated: false, completion: nil)
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

        alertController.addAction(
            UIAlertAction(
                title: config.cancelTitle,
                style: .cancel,
                handler: { _ in viewController.dismiss(animated: false, completion: nil) }
            )
        )

        viewController.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Actions

    /**
     * Called by the gesture recognizer when it is triggered.
     * This will in turn call `showSwitcher` if it is defined, showing the switcher.
     *
     * - parameter sender: A reference to the `UITapGestureRecognizer` that sent the event.
     */
    @objc private func tapHandler(_ sender: UITapGestureRecognizer) {
        showSwitcher?()
    }

    /**
     * Text field event listener, updates the "Use Custom" button as the text field is modified.
     *
     * - parameter sender: A reference to the text field.
     */
    @objc private func textFieldChanged(_ sender: UITextField) {
        guard var text = sender.text else {
            textFieldDoneButton?.isEnabled = false
            return
        }

        if !text.contains("http://") && !text.contains("https://") {
            text = "https://" + text
        }

        self.textFieldDoneButton?.isEnabled = canOpenURL(text)
    }

    // MARK: - Private Helpers

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
     * Called when a new endpoint is selected, broadcast the selection and store the new endpoint.
     *
     * - parameter endpoint: The new endpoint to save.
     */
    private func selected(endpoint: Endpoint) {
        self.endpoint = endpoint
        delegate?.switchcraft(self, didSelectEndpoint: endpoint)
        NotificationCenter.default.post(name: .SwitchcraftDidSelectEndpoint, object: self, userInfo: [Notification.Key.Endpoint: endpoint])
    }

    /**
     * Create and return the default UITapGestureRecognizer recognizer to attach to a view.
     * The default gesture is a three finger double tap unless built with the simulator,
     * in which case it uses a single tap.
     *
     * - parameter viewController: The view controller the switcher will be attached to when displayed.
     *
     * - returns: The new `UITapGestureRecognizer`.
     */
    private func makeDefaultGestureRecognizer(forVC viewController: UIViewController) -> UITapGestureRecognizer {
        showSwitcher = { self.display(from: viewController) }

        let defaultGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))

        // Change default tap behaviour if running on the simulator to use a single tap
        let isSimulator = TARGET_OS_SIMULATOR != 0
        defaultGesture.numberOfTapsRequired = isSimulator ? 1 : 2
        defaultGesture.numberOfTouchesRequired = isSimulator ? 1 : 3
        return defaultGesture
    }
}
