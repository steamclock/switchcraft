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
    @IBOutlet weak var currentEndpointLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showSwitchcraft))
        tapGesture.numberOfTapsRequired = 1 //2
        tapGesture.numberOfTouchesRequired = 1//3
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)

        currentEndpointLabel.text = UserDefaults.standard.string(forKey: "endpoint")
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
        guard let urlString = UserDefaults.standard.string(forKey: "endpoint"), let url = URL(string: urlString) else { return }
        self.present(SFSafariViewController(url: url), animated: true, completion: nil)
    }
}

extension ViewController: SwitchcraftDelegate {
    func switchcraft(_ switchcraft: Switchcraft, didChangeEndpoint endpoint: SwitchcraftEndpoint) {
        currentEndpointLabel.text = endpoint.url
    }
}

