# LaunchDoggly-iOS-demo-app
---
LaunchDoggly is a feature management platform that serves over 100 billion feature flags daily to help teams build better software, faster. Get started using [LaunchDoggly](https://docs.LaunchDoggly.com/docs/getting-started)

- This is a iOS version of the web app.

##### Build instructions
 #####
1. Make sure you have [XCode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12) installed
2. Run 'pod install' to get the latest iOS client integrated.
3. Open `LaunchDoggly.xcworkspace` in XCode
4. Copy the mobile key from your account settings page and set `mobileKey` in `AppDelegate.swift`.
5. Copy the feature flag key from your LaunchDoggly dashboard and set `featureFlagKey` in `ViewController.swift`

6. Run your application through XCode.
7. Update the feature flags from your LaunchDoggly dashboard and the feature flag label in the view controller should update with the current value of the feature flag.

##### Requirements
 #####
LaunchDarkly api key

- create plist called keys.plist and configure it as
: sdk-key: "your-sdk-key"

![login page](https://github.com/BrianJayChung/LaunchDoggly-iOS-app/blob/master/Appscreenshots/login-screen.png)
![flags](https://github.com/BrianJayChung/LaunchDoggly-iOS-app/blob/master/Appscreenshots/flags-screen.png)
