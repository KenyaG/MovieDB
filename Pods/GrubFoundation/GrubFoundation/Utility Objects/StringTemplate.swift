//
//  StringTemplate.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 6/12/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


/// `StringTemplate` provides an efficient, performant mechanism for replacing pre-defined placeholders in a template
/// string with the values they represent. It is designed to efficiently substitute values for the same template many
/// times. It is ideal for implementing behavior like custom formatters with format strings.
///
/// To use `StringTemplate`, you first need to define your placeholders by creating a type that conforms to
/// `StringTemplatePlaceholder`. This type provides a list of placeholders and their associated text. It also has
/// an associated `Substitutions` type that represents the substitutions for your placeholders; this type is used by
/// `StringTemplate` to get the substitutions for your placeholders.
///
/// For example, suppose we want to create a string template that supports showing information about a person. We’ll
/// store that information in a `PersonInfo` `struct`.
///
///     struct PersonInfo {
///         let givenName: String
///         let familyName: String
///         let birthday: Date
///         let height: Measurement<UnitLength>
///         let weight: Measurement<UnitMass>
///     }
///
/// Our `StringTemplatePlaceholder` may then look something like:
///
///     enum PersonInfoPlaceholder : String, StringTemplatePlaceholder {
///         case givenName = "«givenName»"
///         case familyName = "«familyName»"
///         case birthday = "«birthday»"
///         case height = "«height»"
///         case weight = "«weight»"
///
///         struct Values {
///             let personInfo: PersonInfo
///             let measurementFormatter: MeasurementFormatter
///             let dateFormatter: DateFormatter
///         }
///
///         func substitution(from values: Values) -> String {
///             let personInfo = values.personInfo
///
///             switch self {
///             case .givenName:
///                 return personInfo.givenName
///             case .familyName:
///                 return personInfo.familyName
///             case .birthday:
///                 return values.dateFormatter.string(from: personInfo.birthday)
///             case .height:
///                 return values.measurementFormatter.string(from: personInfo.height)
///             case .weight:
///                 return values.measurementFormatter.string(from: personInfo.weight)
///             }
///         }
///     }
///
/// We can then create and use a string template as follows:
///
///     let template = StringTemplate<PersonInfoPlaceholder>("«givenName» «familyName» - «birthday»")
///     let personInfo = PersonInfo(…)
///     let values = PersonInfoPlaceholder.Values(…)
///     let description = template.substituting(values)
///
public struct StringTemplate<Placeholder> where Placeholder : StringTemplatePlaceholder {
    /// The parser that is used to convert a template into template components.
    private let templateParser = TemplateParser<Placeholder>()

    // The components that make up the template string.
    private var templateComponents: [TemplateComponent<Placeholder>]

    /// The template string whose placeholders will be substituted with real values. Any non-placeholder text will not
    /// be modified.
    public var template: String {
        didSet {
            self.templateComponents = templateParser.components(fromTemplate: template)
        }
    }


    /// Creates a new `StringTemplate` with the specified template.
    ///
    /// - Parameter template: The template
    public init(_ template: String) {
        self.template = template
        self.templateComponents = templateParser.components(fromTemplate: template)
    }


    /// Returns a new string by substituting the specified placeholder values for the placeholders in the instance’s
    /// template.
    ///
    /// - Parameter values: The values to substitute.
    public func substituting(_ values: Placeholder.Values) -> String {
        return Placeholder.shouldCacheSubstitutions ? substitutingWithCaching(values) : substitutingWithoutCaching(values)
    }


    /// Performs value substitution without substitution caching. This should only be invoked if
    /// `Placeholder.shouldCacheSubstitutions` is `false`.
    ///
    /// - Parameter values: The values to substitute.
    private func substitutingWithoutCaching(_ values: Placeholder.Values) -> String {
        var substitutedString = ""
        for component in templateComponents {
            switch component {
            case let .literal(string):
                substitutedString.append(string)
            case let .placeholder(placeholder):
                substitutedString.append(placeholder.substitution(from: values))
            }
        }

        return substitutedString
    }


    /// Performs value substitution with substitution caching. This should only be invoked if
    /// `Placeholder.shouldCacheSubstitutions` is `true`.
    ///
    /// - Parameter values: The values to substitute.
    private func substitutingWithCaching(_ values: Placeholder.Values) -> String {
        // A cache of substitutions for placeholders that have already been substituted in this string. We use this to
        // avoid generating substitutions multiple times. This is important when the substitution is expensive to
        // generate, e.g., when formatting a date.
        var substitutionCache: [Placeholder : String] = [:]

        var substitutedString = ""
        for component in templateComponents {
            switch component {
            case let .literal(string):
                substitutedString.append(string)
            case let .placeholder(placeholder):
                // If we’d previously gotten the substitution for this placeholder, use the cached version. Otherwise,
                // generate a new one and cache it.
                let substitution: String
                if let previousSubstitution = substitutionCache[placeholder] {
                    substitution = previousSubstitution
                } else {
                    substitution = placeholder.substitution(from: values)
                    substitutionCache[placeholder] = substitution
                }

                substitutedString.append(substitution)
            }
        }

        return substitutedString
    }
}


// MARK: - String template placeholders

/// Types conforming to `StringTemplatePlaceholder` define the placeholders that can be used in `StringTemplate`s.
/// In addition to simply listing the placeholders and their text, it also provides an associated `Substitutions` type
/// that is used to determine what substitution should be used for a given placeholder. An instance of this type is
/// passed to `substitution(from:)`, which returns the appropriate substitution for the placeholder.
public protocol StringTemplatePlaceholder : CaseIterable, Hashable {
    /// `Values` is an unconstrained type that placeholders use to derive the values they should be substituted with.
    /// This type is often a `struct` that includes either literal values or information that can be used to derive the
    /// value, e.g., a formatter plus some non-`String` data.
    associatedtype Values

    /// Whether substitutions should be cached. `true` by default.
    ///
    /// When `true`, `StringTemplate` will never invoke `substitution(from:)` more than once for each placeholder it
    /// encounters during an execution.
    ///
    /// Your type can return `false` here if generating the substitution is less expensive than the cache lookup or if
    /// you don’t believe the same substitution will occur multiple times.
    static var shouldCacheSubstitutions: Bool { get }

    /// The text of the placeholder. This value may not be a substring of any other placeholder’s text.
    ///
    /// If the type is `RawRepresentable` as a `String`, a default implementation is provided that returns the
    /// instance’s `rawValue`.
    var text: String { get }


    /// Returns the value that should be used in place of the placeholder.
    ///
    /// `StringTemplate` uses this method to get values for placeholders in its `substituting(_:)` method.
    ///
    /// If `Placeholder.shouldCacheSubstitutions` is `true`, that method guarantees that for a single execution, it will
    /// not invoke this method more than once for each placeholder it encounters. As such, there is generally no need to
    /// cache substitutions between invocations of this method unless you intend to invoke `substituting(_:)` multiple
    /// times using the same `Values` instance. This should happen very rarely.
    ///
    /// - Parameter values: An instance of `Values` from which the substitution is derived.
    /// - Returns: The substitution for the placeholder.
    func substitution(from values: Values) -> String
}


public extension StringTemplatePlaceholder {
    static var shouldCacheSubstitutions: Bool {
        return true
    }
}


public extension StringTemplatePlaceholder where Self : RawRepresentable, Self.RawValue == String {
    var text: String {
        return rawValue
    }
}


// MARK: - Template parsing

/// `TemplateParser`s parse string templates into arrays of `TemplateComponent`s.
private class TemplateParser<Placeholder> where Placeholder : StringTemplatePlaceholder {
    /// A regular expression that matches the text of any placeholder.
    private lazy var placeholdersRegularExpression: NSRegularExpression = {
        let escapedPlaceholders = Placeholder.allCases.map { NSRegularExpression.escapedPattern(for: $0.text) }
        let pattern = "(\(escapedPlaceholders.joined(separator: "|")))"

        // swiftlint:disable force_try
        return try! NSRegularExpression(pattern: pattern)
    }()


    /// Parses the string template into an array of `TemplateComponent`s. These components can be used to efficiently
    /// perform substitutions on the template.
    ///
    /// - Parameter template: The template to parse.
    /// - Returns: An array of `TemplateComponent`s representing the template string.
    func components(fromTemplate template: String) -> [TemplateComponent<Placeholder>] {
        // A dictionary that maps a placeholder’s text to the placeholder
        let textToPlaceholders = Dictionary(uniqueKeysWithValues: Placeholder.allCases.map { ($0.text, $0) })

        // The array of components that we’re building up
        var components: [TemplateComponent<Placeholder>] = []

        // The full range of the template string.
        let range = NSRange(template.startIndex ..< template.endIndex, in: template)

        // One past the index of the previously found text. This index is not in the matched range itself. It is updated
        // every time we find a match
        var previousEndIndex = template.startIndex
        placeholdersRegularExpression.enumerateMatches(in: template, options: .reportCompletion, range: range) { (result, flags, _) in
            // If we got to the end of the template and there are characters between previousEndIndex and the end of the
            // string, add one last literal to our list of components
            guard !flags.contains(.completed) else {
                let range = previousEndIndex ..< template.endIndex
                if !range.isEmpty {
                    components.append(.literal(String(template[range])))
                }

                return
            }

            // None of these should ever fail if we got this far
            guard let result = result,
                let resultRange = Range(result.range, in: template),
                let placeholder = textToPlaceholders[String(template[resultRange])] else {
                    return
            }

            // If there are any characters between the previous end index and the result range, we have some literal
            // characters between matches, so we should add a .literal to our components
            if template.distance(from: previousEndIndex, to: resultRange.lowerBound) > 0 {
                components.append(.literal(String(template[previousEndIndex ..< resultRange.lowerBound])))
            }

            // Add the placeholder to our components and move forward our previous end index
            components.append(.placeholder(placeholder))
            previousEndIndex = resultRange.upperBound
        }

        return components
    }
}


/// `TemplateComponent`s represent the components of a template.
private enum TemplateComponent<Placeholder> {
    /// A literal string.
    case literal(String)

    /// A placeholder.
    case placeholder(Placeholder)
}
