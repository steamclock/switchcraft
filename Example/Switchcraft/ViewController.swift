//
//  ViewController.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import SafariServices
import Switchcraft
import UIKit

class ViewController: UIViewController {
    @IBOutlet private var currentEndpointLabel: UILabel!

    private var otherSwitch: Switchcraft?
    @IBOutlet private var otherEndpointLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSwitchcraft))
        tapGesture.numberOfTapsRequired = 1 //2
        tapGesture.numberOfTouchesRequired = 1 //3
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)

        currentEndpointLabel.text = SwitchcraftManager.shared.endpoint
    }

    @objc private func showSwitchcraft() {
        let switchcraft = Switchcraft(title: "Select Endpoint", message: nil, allowCustom: true)

        switchcraft.delegate = self
        switchcraft.addEndpoints([
            SwitchcraftEndpoint(title: "Google", url: "https://google.com"),
            SwitchcraftEndpoint(title: "Apple", url: "https://apple.com"),
            SwitchcraftEndpoint(title: "Amazon", url: "https://amazon.com")
            ])

        self.present(switchcraft, animated: true)
    }

    @IBAction func visitEndpoint(_ sender: UIButton) {
        guard let urlString = SwitchcraftManager.shared.endpoint, let url = URL(string: urlString) else { return }
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    @IBAction func otherEndpointPicker(_ sender: Any) {
        let manager = SwitchcraftManager()
        manager.defaultsKey = "otherEndpoint"

        otherSwitch = Switchcraft(title: "Select Endpoint", message: "Current: " + (manager.endpoint ?? ""), manager: manager)

        otherSwitch?.delegate = self
        otherSwitch!.addEndpoints([
            SwitchcraftEndpoint(title: "Cats", url: "https://cats.com"),
            SwitchcraftEndpoint(title: "Dogs", url: "https://dogs.com"),
            SwitchcraftEndpoint(title: "Birbs", url: "https://birbs.com")
            ])

        self.present(otherSwitch!, animated: true)
    }
}

extension ViewController: SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpoint endpoint: SwitchcraftEndpoint) {
        if switchcraft == otherSwitch {
            otherEndpointLabel.text = endpoint.url
        } else {
            currentEndpointLabel.text = endpoint.url
        }
    }
}

