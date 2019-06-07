# LaunchDarkly-iOS-demo-app
---
LaunchDarkly is a feature management platform that serves over 100 billion feature flags daily to help teams build better software, faster. Get started using [LaunchDarkly](https://docs.launchdarkly.com/docs/getting-started)

- This is app demonstrates feature flagging using LaunchDarkly's Swift SDK.

##### Build instructions
 #####
1. Make sure you have [XCode](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12) installed
2. Run 'pod install' to get the latest iOS client integrated.
3. Open `LaunchDoggly.xcworkspace` in XCode
4. Copy the mobile key from your account settings page and set `mobileKey` in `AppDelegate.swift`.
5. Copy the feature flag key from your LaunchDarkly dashboard and set `featureFlagKey` in `ViewController.swift`

6. Run your application through XCode.
7. Update the feature flags from your LaunchDarkly dashboard and the feature flag label in the view controller should update with the current value of the feature flag.

