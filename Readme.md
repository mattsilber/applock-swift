SwiftyAppLock - the iOS version of https://github.com/mattsilber/applock.git

#### CocoaPods
```ruby
pod 'SwiftyAppLock', :git => 'git@github.com:mattsilber/applock-swift.git', :tag => '1.0.0'
```

### Usage

#### PIN Creation

First thing you're going to want to do is ask your users to create a PIN.

```swift
AppLock.shared.create(
    on: self,
    withWindowStyle: .dialog,
    creationAborted: { print("AppLock Create Aborted") },
    creationError: { print("AppLock Create Error: \($0)") },
    pinCreated: { print("Created PIN Hash: \($0)") })
```

If you want to know whether or not a PIN has already been set for the application, you can just check `AppLock.shared.pinExists`.

#### Unlocking

Now that the content is locked, you might want to unlock it...

```swift
AppLock.shared.attach(
    to: self,
    authenticatingWith: .always,
    withWindowStyle: .fullsreen,
    pinNotPresent: { print("No PIN exists, should they create one?") },
    unlockAbortRequested: { appLockView in
       print("Abort requested, close the dialog?")
       // appLockView.dismiss() 
    },
    unlockRetryExceeded: { view, date in
       print(AppLock.shared.limitExceededMessage)
    },
    unlockSuccess: { print("Unlocked!") })
```

If you want to prevent an entire UIViewController from being displayed based on a timed expiration, you can do something like:

```swift
obverride func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    AppLock.shared.attach(
        to: self,
        authenticatingWith: .timedExpiration(seconds: 60 * 15),
        unlockAbortRequested: { [weak self] appLockView  in
            self?.navigationController?.popViewController()
        })
```

#### Themes

Because everybody loves a little bit of color.

Almost every color is customizable by adjusting the `AppLockView.Theme`. There's also a convenience function to change the general theme:

```swift
AppLock.shared.theme = AppLock.generateTheme(
    primaryColor: UIColor.blue,
    primaryColorDisabled: UIColor.red,
    secondaryColor: UIColor.lightGray)
``` 

#### Configs and Messages

Several things can be configured via `AppLock.shared.configs`, such as the PIN length, default session expiration, max unlock retries, etc.

All of the messages can also be overriden by setting `AppLock.shared.messages`.
