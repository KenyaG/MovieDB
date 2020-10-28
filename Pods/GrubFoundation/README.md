# GrubFoundation


GrubFoundation is a framework for Apple platforms that provides a base level of objects for building
frameworks and apps. It provides types and protocols for

  - Easily consuming web services
  - Logging to a wide variety of destinations
  - Declaratively validating values
  - Concurrently accessing data structures
  - And more!

It is a dependency for many Grubhub frameworks.

GrubFoundation supports iOS 11+, macOS 10.13+, and tvOS 11+ and is implemented in Swift.

## Guides

Given the variety of functionality provided by GrubFoundation, it’s difficult to document it in a
README. We’ve written a few guides to get you started with the larger subsystems:

  - [Logging](Documentation/Logging.md)
  - [Handlers and Transformers](Documentation/HandlersAndTransformers.md)
  - [Networking](Documentation/Networking.md)
  - [Validators](Documentation/Validators.md)

In addition, GrubFoundation has documentation for all its public APIs in the source files
themselves. Bringing up quick help in Xcode should help you understand how to use a type or method.


## What’s New

See the [change log](CHANGELOG.md) for a list of what’s new in the latest (and previous) releases.


## Installing GrubFoundation

To add GrubFoundation to your project, you need to add the DinerSpecs repo as a source in your
Podfile.

    source 'git@github.com:GrubhubProd/DinerSpecs.git'

You can then include the GrubFoundation pod.

    pod 'GrubFoundation'


## Development Requirements

To work on GrubFoundation, you need Xcode 11.4+. Clone the repo and open
`GrubFoundation.xcworkspace`. All GrubFoundation source code must follow the [Diner
Swift][DinerSwiftStyle] style guide. Public interfaces must follow the [Swift API Design
Guidelines][SwiftAPIDesignGuidelines] Furthermore all public interfaces must be documented and unit
tested. We want overall test coverage to be over 98%.

[DinerSwiftStyle]: https://github.com/GrubhubProd/guides/blob/master/iOS/SwiftStyleGuide.md
[SwiftAPIDesignGuidelines]: https://swift.org/documentation/api-design-guidelines/


## Questions, Comments, Feature Requests, and Bugs

GrubFoundation strives to be well-documented, well-tested, and bug-free. If you have questions or
comments about it, email [Prachi Gauriar](mailto:pgauriar@grubhub.com). Feature requests will also
be considered, provided they fit within the goals of the framework.
