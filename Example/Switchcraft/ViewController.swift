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
        SwitchcraftManager.shared.allowCustom = true
        let switchcraft = Switchcraft(endpoints: [
            SwitchcraftEndpoint(title: "Google", url: "https://google.com"),
            SwitchcraftEndpoint(title: "Apple", url: "https://apple.com"),
            SwitchcraftEndpoint(title: "Amazon", url: "https://amazon.com")
            ]
        )
        switchcraft.delegate = self

        self.present(switchcraft, animated: true)
    }

    @IBAction func visitEndpoint(_ sender: UIButton) {
        guard let urlString = SwitchcraftManager.shared.endpoint, let url = URL(string: urlString) else { return }
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
}

extension ViewController: SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpoint endpoint: SwitchcraftEndpoint) {
        currentEndpointLabel.text = endpoint.url
    }
}

