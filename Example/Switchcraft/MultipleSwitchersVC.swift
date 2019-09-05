//
//  MultipleSwitchersVC.swift
//  Switchcraft_Example
//
//  Created by Brendan Lensink on 2018-04-30.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SafariServices
import Switchcraft
import UIKit

class MultipleSwitchersVC: UIViewController {
    @IBOutlet weak var openFirstLabel: UILabel!
    @IBOutlet weak var visitFirstButton: UIButton!

    @IBOutlet weak var openSecondLabel: UILabel!
    @IBOutlet weak var visitSecondButton: UIButton!

    private var firstSwitcher: Switchcraft!
    private var secondSwitcher: Switchcraft!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let firstConfig = Config(
            defaultsKey: "firstEndpoint",
            endpoints: [
                Endpoint(title: "Math Cats", url: URL(string: "https://en.wikipedia.org/wiki/CAT(k)_space")!),
                Endpoint(title: "Computer Cats", url: URL(string: "https://en.wikipedia.org/wiki/Cat_(Unix)")!),
                Endpoint(title: "Cat Cats 🐱", url: URL(string: "https://en.wikipedia.org/wiki/Cat")!)
            ]
        )
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFirst(_:)))
        tapGesture.numberOfTouchesRequired = 2

        firstSwitcher = Switchcraft(config: firstConfig)
        firstSwitcher.attachGesture(to: self, gestureView: openFirstLabel, gestureRecognizer: tapGesture)

        let secondConfig = Config(
            defaultsKey: "secondEndpoint",
            endpoints: [
                Endpoint(title: "Musical Doggos", url: URL(string: "https://en.wikipedia.org/wiki/Dogs_(Pink_Floyd_song)")!),
                Endpoint(title: "Bright Doggos", url: URL(string: "https://en.wikipedia.org/wiki/Sun_dog")!),
                Endpoint(title: "Dog Doggos 🐕", url: URL(string: "https://en.wikipedia.org/wiki/Dog")!)
            ]
        )
        secondSwitcher = Switchcraft(config: secondConfig)
        secondSwitcher.attachGesture(to: self)
    }

    @objc private func show(_ gestureRecognizer: UITapGestureRecognizer) {
        print("show")
    }

    @IBAction func visitTouched(_ sender: UIButton) {
        switch sender {
        case visitFirstButton: visit(firstSwitcher.endpoint)
        case visitSecondButton: visit(secondSwitcher.endpoint)
        default: break
        }
    }

    @objc private func showFirst(_ gestureRecognizer: UITapGestureRecognizer) {
        firstSwitcher.display(from: self)
    }

    private func visit(_ endpoint: Endpoint?) {
        guard let endpoint = endpoint else { return }
        self.present(SFSafariViewController(url: endpoint.url), animated: true, completion: nil)
    }
}
