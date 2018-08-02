//
//  AppDelegate.swift
//  Switchcraft
//
//  Created by brendan@steamclock.com on 03/29/2018.
//  Copyright (c) 2018 Steamclock Software. All rights reserved.
//

import Switchcraft
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

extension Switchcraft {
    static let shared = Switchcraft(config: Config(
        defaultsKey: "simpleEndpoint",
        endpoints: [
            Endpoint(title: "Production", url: URL(string: "https://google.com")!),
            Endpoint(title: "QA", url: URL(string: "http://apple.com")!),
            Endpoint(title: "Development", url: URL(string: "http://steamclock.com")!)
        ],
//        actions: [
//            Action(title: "Custom action 1", actionId: Actions.custom1.rawValue),
//            Action(title: "Custom action 2", actionId: Actions.custom2.rawValue)
//        ],
        allowCustom: false
    ))
}

enum Actions: String {
    case custom1
    case custom2
}
