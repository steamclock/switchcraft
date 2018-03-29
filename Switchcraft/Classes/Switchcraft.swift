//
//  Switchcraft.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

public struct SwitchcraftEndpoint {
    public let title: String?
    public let url: String
    public let style: UIAlertActionStyle

    public init(title: String?, url: String, style: UIAlertActionStyle = . default) {
        self.title = title
        self.url = url
        self.style = style
    }
}

public protocol SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpoint endpoint: SwitchcraftEndpoint)
}

public class Switchcraft: UIViewController {

    private var alertController: UIAlertController?
    private var alertTitle: String?
    private var alertMessage: String?
    private var allowCustom: Bool = false
    private(set) var endpoints: [SwitchcraftEndpoint] = []

    public var delegate: SwitchcraftDelegate?

    private var textFieldDoneButton: UIAlertAction?

    public convenience init(title: String?, message: String?, allowCustom: Bool = false) {
        self.init(nibName: nil, bundle: nil)

        alertTitle = title
        alertMessage = message
        self.allowCustom = allowCustom

        modalPresentationStyle = .overCurrentContext
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: allowCustom ? .alert : .actionSheet)

        if allowCustom {
            textFieldDoneButton = UIAlertAction(title: "Done", style: .default, handler: { _ in
                guard let textField = self.alertController?.textFields?.first, let text = textField.text else {
                    return
                }
                let newEndpoint = SwitchcraftEndpoint(title: nil, url: text)
                self.selected(endpoint: newEndpoint)
            })
            alertController?.addAction(textFieldDoneButton!)

            alertController?.addTextField (configurationHandler: { textField in
                textField.placeholder = "Enter value"
                textField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
            })
        }

        for endpoint in endpoints {
            alertController?.addAction(
                // TODO: Better default value for title, can atleast strip http, etc
                UIAlertAction(title: endpoint.title ?? endpoint.url, style: endpoint.style, handler: { [weak self] (action) in
                    self?.selected(endpoint: endpoint)
                })
            )
        }

        alertController?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController!, animated: true, completion: nil)
    }

    override public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        alertController?.dismiss(animated: animated, completion: nil)
        super.dismiss(animated: animated, completion: completion)
    }

    public func addEndpoint(_ endpoint: SwitchcraftEndpoint) {
        endpoints.append(endpoint)
    }

    public func addEndpoints(_ endpoints: [SwitchcraftEndpoint]) {
        self.endpoints.append(contentsOf: endpoints)
    }

    private func selected(endpoint: SwitchcraftEndpoint) {
        delegate?.switchcraft(self, didChangeEndpoint: endpoint)
    }

    @objc private func textFieldChanged(_ sender: UITextField) {
        guard let url = URL(string: sender.text ?? "") else {
            return
        }

        self.textFieldDoneButton?.isEnabled = UIApplication.shared.canOpenURL(url)
    }
}
