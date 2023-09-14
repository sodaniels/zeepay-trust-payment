fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios clearDerivedData

```sh
[bundle exec] fastlane ios clearDerivedData
```

Clear Derived Data

### ios threeDModuleTests

```sh
[bundle exec] fastlane ios threeDModuleTests
```

Run unit tests for the 3D Secure module

### ios cardModuleTests

```sh
[bundle exec] fastlane ios cardModuleTests
```

Run unit tests for the Card module

### ios coreModuleTests

```sh
[bundle exec] fastlane ios coreModuleTests
```

Run unit tests for the Core module

### ios uiModuleTests

```sh
[bundle exec] fastlane ios uiModuleTests
```

Run unit tests for the UI module

### ios sslPinningTests

```sh
[bundle exec] fastlane ios sslPinningTests
```

Run ssl pinning tests

### ios staticAnalysis

```sh
[bundle exec] fastlane ios staticAnalysis
```

Perform Static Analysis

### ios exampleAppUITests

```sh
[bundle exec] fastlane ios exampleAppUITests
```

Run UI tests for the Example App

### ios exampleAppUITestsBrowserStack

```sh
[bundle exec] fastlane ios exampleAppUITestsBrowserStack
```

Run E2E tests on BrowserStack.

### ios exampleAppIntegrationTests

```sh
[bundle exec] fastlane ios exampleAppIntegrationTests
```

Run integration & unit tests for the Example App

### ios exampleAppUnitLocaleTests

```sh
[bundle exec] fastlane ios exampleAppUnitLocaleTests
```

Run unit tests(locale) for the Example App

### ios exampleAppSnapshotTests

```sh
[bundle exec] fastlane ios exampleAppSnapshotTests
```

Run Snapshot test

### ios exampleAppIphone5sSmokeTests

```sh
[bundle exec] fastlane ios exampleAppIphone5sSmokeTests
```

Run only E2E UI tests on iOS 12.4

### ios combinedCodeCoverage

```sh
[bundle exec] fastlane ios combinedCodeCoverage
```

Collects code coverage for selected lanes, combines them display total code coverage for SDK modules

### ios carthageIntegrationTests

```sh
[bundle exec] fastlane ios carthageIntegrationTests
```

Run selected UI and Unit tests at once for the Carthage Integration

### ios cocoaPodsIntegrationTests

```sh
[bundle exec] fastlane ios cocoaPodsIntegrationTests
```

Run selected UI and Unit tests for the CocoaPods Integration

### ios runTests

```sh
[bundle exec] fastlane ios runTests
```



### ios buildApp

```sh
[bundle exec] fastlane ios buildApp
```

Build app for App Store or Ad Hoc

### ios prepareTestSuiteForBrowserStack

```sh
[bundle exec] fastlane ios prepareTestSuiteForBrowserStack
```

Build the project to generate E2E test-suite for BrowserStack.

### ios upload

```sh
[bundle exec] fastlane ios upload
```

Upload build to TestFlight

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
