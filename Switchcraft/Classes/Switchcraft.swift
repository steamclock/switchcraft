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
    private var manager: SwitchcraftManager = SwitchcraftManager.shared
    private(set) var endpoints: [SwitchcraftEndpoint] = []
    private var textFieldDoneButton: UIAlertAction?

    public var delegate: SwitchcraftDelegate?

    public convenience init(manager: SwitchcraftManager = SwitchcraftManager.shared) {
        self.init(nibName: nil, bundle: nil)

        self.manager = manager

        modalPresentationStyle = .overCurrentContext
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alertController = UIAlertController(title: manager.alertTitle, message: manager.alertMessage, preferredStyle: manager.allowCustom ? .alert : .actionSheet)

        if manager.allowCustom {
            textFieldDoneButton = UIAlertAction(title: manager.textFieldDoneTitle, style: .default, handler: { _ in
                guard let textField = self.alertController?.textFields?.first, let text = textField.text else {
                    return
                }
                let newEndpoint = SwitchcraftEndpoint(title: nil, url: text)
                self.selected(endpoint: newEndpoint)
            })
            alertController?.addAction(textFieldDoneButton!)

            alertController?.addTextField (configurationHandler: { textField in
                textField.placeholder = self.manager.textFieldPlaceholder
                textField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                textField.text = self.manager.endpoint
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

        alertController?.addAction(UIAlertAction(title: manager.cancelTitle, style: .cancel, handler: nil))

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

    public func endpoint() -> String? {
        return manager.endpoint
    }

    private func selected(endpoint: SwitchcraftEndpoint) {
        manager.endpoint = endpoint.url
        delegate?.switchcraft(self, didChangeEndpoint: endpoint)
    }

    @objc private func textFieldChanged(_ sender: UITextField) {
        guard let url = URL(string: sender.text ?? "") else {
            return
        }

        self.textFieldDoneButton?.isEnabled = UIApplication.shared.canOpenURL(url)
    }
}
