# GrubTest

GrubTest is a small testing framework that extends XCTest with helpful classes and methods. It adds
helpers to generate random values to use in your testsd. It also provides useful utility objects
for writing stubs.

GrubTest supports testing Swift code on macOS 10.13+, iOS 11+, and tvOS 11+ targets.


## What’s New

See the [change log](CHANGELOG.md) for a list of what’s new in the latest (and previous) releases.


## Installing GrubTest

To add GrubTest to your project, you need to add the DinerSpecs repo as a source in your Podfile.

    source 'git@github.com:GrubhubProd/DinerSpecs.git'

Then, add GrubTest to your Podfile:

    pod 'GrubTest'


## Using GrubTest

To use GrubTest in your unit tests, import the GrubTest framework and make your test case class a
subclass of `RandomizedTestCase`.

    import GrubTest
    import XCTest


    final class MyClassTests : RandomizedTestCase {
        // …
    }

When subclassing `RandomizedTestCase`, if you override the `setUp` class or instance methods, you
must invoke the superclass implementations. Failing to do so will lead to unrepeatable random tests.
After that, you can invoke `RandomizedTestCase` methods as normal to generate random data. For
example, the code below creates a dictionary of random strings that map to random dates.

    import GrubTest
    import XCTest


    final class MyClassTests : RandomizedTestCase {
        private var stringsToDates: [String : Date] = [:]

        override func setUp() {
            super.setUp()

            stringsToDates = generatedDictionary(count: 10, keyGenerator: {
                return randomInternationalString()
            }, valueGenerator: { _ in
                return randomDate()
            })
        }


        func testMyMethod() {
            let instance = MyClass()

            for (string, date) in stringsToDates {
                instance.doSomething(with: string, after: date)

                // Assertions here
            }
        }
    }


## Development Requirements

To work on GrubTest, you need Xcode 11.4. Clone the repo and open `GrubTest.xcodeproj`. All GrubTest
source code must follow the [Diner Swift][DinerSwiftStyle] style guides. Public interfaces must
follow the [Swift API Design Guidelines][SwiftAPIDesignGuidelines]. Furthermore all public
interfaces must be documented and unit tested. We want overall test coverage to be over 98%.

[DinerSwiftStyle]: https://github.com/GrubhubProd/guides/blob/master/iOS/SwiftStyleGuide.md
[SwiftAPIDesignGuidelines]: https://swift.org/documentation/api-design-guidelines/


## Questions, Comments, Feature Requests, and Bugs

GrubTest strives to be well-documented, well-tested, and bug-free. If you have questions or comments
about it, email [Prachi Gauriar](mailto:pgauriar@grubhub.com). Feature requests will also be
considered, provided they fit within the goals of the GrubTest framework.
