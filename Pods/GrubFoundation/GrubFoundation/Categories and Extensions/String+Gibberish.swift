//
//  String+Gibberish.swift
//  GrubFoundation
//
//  Created by Prachi Gauriar on 12/28/2019.
//  Copyright © 2019 Grubhub, Inc. All rights reserved.
//

import Foundation


public extension String {
    /// Returns a random gibberish word.
    ///
    /// Randomness is provided by `SystemRandomNumberGenerator`.
    static func randomGibberishWord() -> String {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return randomGibberishWord(using: &randomNumberGenerator)
    }


    /// Returns a random gibberish word using the specified random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator to use for randomness.
    static func randomGibberishWord<RNG>(using randomNumberGenerator: inout RNG) -> String
        where RNG : RandomNumberGenerator {
            return Lexicon.default.words.randomElement(using: &randomNumberGenerator)!
    }


    /// Returns a random sentence of gibberish words.
    ///
    /// Randomness is provided by `SystemRandomNumberGenerator`.
    static func randomGibberishSentence() -> String {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return randomGibberishSentence(using: &randomNumberGenerator)
    }


    /// Returns a random sentence of gibberish words using the specified random number generator.
    ///
    /// - Parameter randomNumberGenerator: The random number generator to use for randomness.
    static func randomGibberishSentence<RNG>(using randomNumberGenerator: inout RNG) -> String
        where RNG : RandomNumberGenerator {
            let sentenceTemplate = Lexicon.default.sentenceTemplates.randomElement(using: &randomNumberGenerator)!
            let words = (0 ..< Lexicon.Placeholder.requiredValueCount).map { _ in
                randomGibberishWord(using: &randomNumberGenerator)
            }

            return sentenceTemplate.substituting(words)
    }


    /// Returns a random paragraph of gibberish sentences.
    ///
    /// Randomness is provided by `SystemRandomNumberGenerator`.
    ///
    /// - Parameter sentenceCount: The number of sentences that the paragraph should contain. If `nil`, a random number
    ///   between 3 and 7 is used.
    static func randomGibberishParagraph(sentenceCount: Int? = nil) -> String {
        var randomNumberGenerator = SystemRandomNumberGenerator()
        return randomGibberishParagraph(sentenceCount: sentenceCount, using: &randomNumberGenerator)

    }


    /// Returns a random paragraph of gibberish sentences using the specified random number generator.
    ///
    /// - Parameter sentenceCount: The number of sentences that the paragraph should contain. If `nil`, a random number
    ///   between 3 and 7 is used.
    static func randomGibberishParagraph<RNG>(sentenceCount: Int? = nil, using randomNumberGenerator: inout RNG) -> String
        where RNG : RandomNumberGenerator {
            let sentenceCount = sentenceCount ?? Int.random(in: 3 ... 7, using: &randomNumberGenerator)
            guard sentenceCount > 0 else {
                return ""
            }

            return (0 ..< sentenceCount)
                .map { _ in randomGibberishSentence(using: &randomNumberGenerator) }
                .joined(separator: " ")
    }
}


/// The `Lexicon` type contains words and sentence templates for gibberish generation.
private final class Lexicon : Decodable {
    init(words: [String], sentenceTemplates: [String]) {
        self.words = words
        self.sentenceTemplates = sentenceTemplates.map { StringTemplate<Placeholder>($0) }
    }


    /// Returns the shared lexicon, which is loaded from Lexicon.plist in the main bundle.
    static let `default`: Lexicon = {
        let url = Bundle.grubFoundation.url(forResource: "GibberishLexicon", withExtension: "json")!

        // swiftlint:disable force_try
        return try! JSONDecoder().decode(Lexicon.self, from: try Data(contentsOf: url))
    }()


    /// The gibberish words to use during generation.
    let words: [String]

    /// The templates used by the generator to generate sentences. These strings are composed of `Placeholder` tokens
    /// separated by spaces and punctuation.
    let sentenceTemplates: [StringTemplate<Placeholder>]


    // MARK: - Decodable

    enum CodingKeys : String, CodingKey {
        case words
        case sentenceTemplates
    }


    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let words = try container.decode([String].self, forKey: .words)
        let sentenceTemplates = try container.decode([String].self, forKey: .sentenceTemplates)
        self.init(words: words, sentenceTemplates: sentenceTemplates)
    }


    // MARK: - Placeholder Strings

    /// The set of tokens that will be replaced during gibberish generation.
    enum Placeholder : String, StringTemplatePlaceholder {
        case word1 = "«1»"
        case word2 = "«2»"
        case word3 = "«3»"
        case word4 = "«4»"
        case word5 = "«5»"
        case word6 = "«6»"
        case word7 = "«7»"
        case word8 = "«8»"
        case word9 = "«9»"
        case word10 = "«10»"
        case word11 = "«11»"
        case word12 = "«12»"
        case word13 = "«13»"
        case word14 = "«14»"
        case word15 = "«15»"


        static var shouldCacheSubstitutions: Bool {
            return false
        }


        /// The number of required values for performing a substitution.
        static var requiredValueCount: Int {
            return allCases.count
        }


        func substitution(from values: [String]) -> String {
            // This code will crash if there are fewer than 15 words in the list, but given that this is internal and
            // the lexicon is private to the framework, this should be fine.
            switch self {
            case .word1:
                return values[0].localizedCapitalized
            case .word2:
                return values[1]
            case .word3:
                return values[2]
            case .word4:
                return values[3]
            case .word5:
                return values[4]
            case .word6:
                return values[5]
            case .word7:
                return values[6]
            case .word8:
                return values[7]
            case .word9:
                return values[8]
            case .word10:
                return values[9]
            case .word11:
                return values[10]
            case .word12:
                return values[11]
            case .word13:
                return values[12]
            case .word14:
                return values[13]
            case .word15:
                return values[14]
            }
        }
    }
}
