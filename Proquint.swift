import Foundation

struct Proquint {

    private static let consonants = "bdfghjklmnprstvz"
    private static let vowels = "aiou"

    /// Converts a UInt32 value to a proquint string.
    /// - Parameters:
    ///   - value: The UInt32 value to encode.
    ///   - separator: An optional separator character to insert between the two 16-bit quint parts.
    /// - Returns: The proquint string representation.
    static func encode(_ value: UInt32, _ separator: Character? = nil) -> String {
        var result = ""
        var currentValue = value
        let bitWidths = [4, 2, 4, 2, 4]
        for part in 0..<2 {
            for bitWidth in bitWidths {
                let mask: UInt32 = bitWidth == 4 ? 0xF0000000 : 0xC0000000
                var segment = currentValue & mask
                currentValue <<= UInt32(bitWidth)
                segment >>= 32 - UInt32(bitWidth)
                let characterSet = bitWidth == 4 ? consonants : vowels
                let index = Int(segment)
                let character = characterSet[characterSet
                    .index(characterSet.startIndex, offsetBy: index)]
                result.append(character)
            }
            if part == 0, let sep = separator {
                result.append(sep)
            }
        }
        return result
    }

    /// Converts a proquint string back to a UInt32 value, ignoring non-coding characters like separators.
    /// - Parameter proquint: The proquint string to decode.
    /// - Returns: The decoded UInt32 value.
    static func decode(_ proquint: String) -> UInt32 {
        var result: UInt32 = 0
        for character in proquint {
            if let consonantIndex = consonants.firstIndex(of: character) {
                result <<= 4
                result += UInt32(consonants.distance(from: consonants.startIndex,
                                                       to: consonantIndex))
            } else if let vowelIndex = vowels.firstIndex(of: character) {
                result <<= 2
                result += UInt32(vowels.distance(from: vowels.startIndex,
                                                   to: vowelIndex))
            }
            // Skip separators or invalid characters
        }
        return result
    }
}

//  Convert between proquint, hex, and decimal strings.
//  Please see the article on proquints: http://arXiv.org/html/0901.4016
//
//  This file is a Swift adaptation of the original proquint implementation.
//  Original: http://github.com/dsw/proquint
//  See License.txt for copyright and terms of use.
//
// https://gist.github.com/leok7v/afec90425c24b88684666fd7cf1ff878
