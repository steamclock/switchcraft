# Switchcraft

[![Version](https://img.shields.io/cocoapods/v/Switchcraft.svg?style=flat)](http://cocoapods.org/pods/Switchcraft)
[![License](https://img.shields.io/cocoapods/l/Switchcraft.svg?style=flat)](https://github.com/steamclock/switchcraft/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/Switchcraft.svg?style=flat)](http://cocoapods.org/pods/Switchcraft)

![Switcher](demoImages/switcher.png?raw=true "Switcher")
![Switcher with custom URL](demoImages/switcherCustom.png?raw=true "Switcher with custom  URL")

## Contents

- [Description](#description)
- [Usage](#usage)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Description

Switchcraft is a simple tool designed to make switching between different endpoints a breeze.

It is designed to be dropped into an existing project and forgotten, but also supports configuring multiple instances and lots of other neat things.

## Usage

### Managing a Single Instance

The simplest way to use Switchcraft is to declare a single global instance, we recommend in your `AppDelegate.swift`, as follows:
```swift
extension Switchcraft {
    static let shared = Switchcraft(config: /*..*/)
}
```
Then, from your ViewController where you'd like to show the picker, all you need to do is attach the `Switchcraft` gesture recognizer to a view controller:
```swift
Switchcraft.shared.attachGesture(to: self)
```
Then you can retrieve the current endpoint from anywhere with
```swift
Switchcraft.shared.endpoint
```

To see this in action, check out the [ReallySimpleExampleVC](https://github.com/steamclock/switchcraft/blob/master/Example/Switchcraft/ReallySimpleExampleVC.swift).

### Keeping Current

To get updates whenever an endpoint is selected, you've got two options:

1. Delegation

    If you only need to keep track of changes to the current endpoint in a single place, this is probably the way to go.
    Classes that want to receive updates only need to register your `viewController` as a delegate and conform to the `SwitchcraftDelegate` protocol.

    ```
    class MyVC: UIViewController {
        // ...

        override func viewDidLoad() {
            super.viewDidLoad()

            Switchcraft.delegate = self
        }
    }

    extension MyVC: SwitchcraftDelegate {
        func switchcraft(_ switchcraft: Switchcraft, didSelectEndpoint endpoint: Endpoint) {
            // Handle your endpoint selection here
        }
    }
    ```

2. `NotificationCenter`

    Endpoint selections are also broadcast to the `NotificationCenter`.

    ```
    NotificationCenter.default.addObserver(self, selector: #selector(endpointSelected(_:)), name: .SwitchcraftDidSelectEndpoint, object: nil)

    ...

    @objc private func endpointSelected(_ sender: NSNotification) {
        guard let endpoint = sender.userInfo?[Notification.Key.Endpoint] as? Endpoint else {
            return
        }
        // Handle endpoint selected here
    }
    ```

### Custom Actions

1. Add some custom actions to Switchcraft via the `Config`:
```swift
extension Switchcraft {
    static let shared = Switchcraft(config: Config(
            defaultsKey: ...,
            endpoints: ...,
            actions: [
                Action(title: "Custom action 1", actionId: "customAction1"),
                Action(title: "Custom action 2", actionId: "customAction2")
            ]
        ))
}
```

2. Add the following to your SwitchCraftDelegate:
```swift
extension MyVC: SwitchcraftDelegate {
    ...

    func switchcraft(_ switchcraft: Switchcraft, didTapAction action: Action)
        // Handle custom action selection here
    }
}
```

Note: We recommend using Swift enums for the actionId, like the following example:
```swift
enum Actions: String {
    case custom1
    case custom2
}

extension Switchcraft {
    static let shared = Switchcraft(config: Config(
            defaultsKey: ...,
            endpoints: ...,
            actions: [
                Action(title: "Custom action 1", actionId: Actions.custom1.rawValue),
                Action(title: "Custom action 2", actionId: Actions.custom2.rawValue)
            ]
        ))
}

extension MyVC: SwitchcraftDelegate {
    ...

    func switchcraft(_ switchcraft: Switchcraft, didTapAction action: Action) {
        guard let action = Actions(rawValue: action.actionId) else {
            return
        }

        switch action {
        case .custom1:
            // handle the first custom action tapped
            ...
        case .custom2:
            // handle the second custom action tapped
            ...
        }
    }
}

```

### Getting Fancy

There are lots of knobs to tweak in your config. See [Config.swift](https://github.com/steamclock/switchcraft/blob/master/Sources/Switchcraft/Config.swift) for a full list.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 9.3 or above
- Xcode 10 or above
- Swift 4.2 or above

## Installation

### Swift Package Manager
Switchcraft is available through Swift Package Manager. To install it, follow these steps:

1. In Xcode, click File, then Swift Package Manager, then Add Package Dependency
2. Choose your project
3. Enter this URL in the search bar https://github.com/steamclock/switchcraft.git

### Cocoapods

Switchcraft is also available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Switchcraft'
```

## Author

brendan@steamclock.com

## License

Switchcraft is available under the MIT license. See the [LICENSE](https://github.com/steamclock/switchcraft/blob/master/LICENSE) file for more info.
