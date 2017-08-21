//: [Previous](@previous)  [Next](@next)
import Foundation

//: # Arrays and Strings

/*: ---
 ## 1.1 **Is Unique:** Implement an algorithm to determine if a string has all unique characters.
 */

func allCharactersUnique(in string: String) -> Bool {
    var charSet = Set<Character>()
    for character in string.characters {
        guard !charSet.contains(character) else { return false }
        charSet.insert(character)
    }

    return true
}

allCharactersUnique(in: "abcd")
allCharactersUnique(in: "aaaa")
allCharactersUnique(in: "Example: 1.1 **Is Unique:** Implement an algorithm to determine if a string has all unique characters.")

//: - Example: What if you can't use additional data structures?

func allCharactersUnique2(in string: String) -> Bool {
    let sortedChars = string.characters.sorted()
    var previousChar = sortedChars.first
    for char in sortedChars.dropFirst() {
        if char == previousChar { return false }
        previousChar = char
    }

    return true
}

allCharactersUnique2(in: "abcd")
allCharactersUnique2(in: "aaaa")
allCharactersUnique2(in: "Example: 1.1 **Is Unique:** Implement an algorithm to determine if a string has all unique characters.")

//: - Example: Assume the character set is extended ASCII (i.e., 256 possible characters) only

func allCharactersUnique3(in string: String) -> Bool {
    var foundChars = Array<Bool>(repeating: false, count: 256)
    for char in string.unicodeScalars {
        assert(char.value < 256)
        if foundChars[Int(char.value)] == true { return false }
        foundChars[Int(char.value)] = true
    }

    return true
}

allCharactersUnique3(in: "abcd")
allCharactersUnique3(in: "aaaa")
allCharactersUnique3(in: "Example: 1.1 **Is Unique:** Implement an algorithm to determine if a string has all unique characters.")


/*: ---
 ## 1.2 Check Permutation: Given two strings, write a method to decide if one is a permutation of the other
 
 *Plan:*
 1. traverse characters in first string, adding each to a hash table with the character as key and the count as value
 2. traverse characters in second string:
    1. if char not found, not a permutation
    2. if char found, decrement count
    3. if count decremented to zero, remove char from hash
 3. if hash table is empty, it's a permutation, otherwise not
 */

extension String {
    func isPermutation(of string: String) -> Bool {
        var charDict = [Character: Int]()
        for char in string.characters {
            guard let charCount = charDict[char] else {
                charDict[char] = 1
                continue
            }

            charDict[char] = charCount + 1
        }

        for char in self.characters {
            guard let charCount = charDict[char] else { return false }
            if charCount == 1 {
                charDict.removeValue(forKey: char)
            }
            else {
                charDict[char] = charCount - 1
            }
        }

        return charDict.count == 0
    }
}

"abcd".isPermutation(of: "cdba")
"aabbccdd".isPermutation(of: "abcdabcd")
"aabbccdd".isPermutation(of: "abcdabcde")
"aabbccdde".isPermutation(of: "abcdabcd")
"😀😁😂😊🙃".isPermutation(of: "🙃😂😀😁😊")

/*: ---
 ## 1.3 URLify: Write a method to replace all spaces in a string with '%20'. 
 You may assume that the string has sufficient space at the end to hold the additional characters, and that you are given the "true" length of the string. If implementing in Java, please use a character array so that you can perform this operation in place.
 
 - Example: Input:    `"Mr John Smith    ", 13`\
            Output    `"Mr%20John%20Smith"`
 
 - Attention: Doing this in Swift without using the Swift Standard Library is entirely too contrived. Therefore, I'm doing it in C.
 */

/*:

````
#include <stdio.h>

/\*!
 * A function to replace all spaces in `url` with `%20` in place.
 * @param url a URL containing spaces (note: this is assumed to have exactly enough space to store all the "expanded" spaces)
 * @param length the length of the URL in characters
 *\/

void URLify(char *url, int length) {
    int spaceCount = 0;
    for (int i = 0; i < length; ++i) {
        if (url[i] == ' ') { spaceCount++; }
    }

    for (int readIndex = length - 1, writeIndex = readIndex + (spaceCount * 2); readIndex >= 0; --readIndex, --writeIndex) {
        switch (url[readIndex]) {
        case ' ':
            writeIndex -= 2;
            url[writeIndex] = '%';
            url[writeIndex + 1] = '2';
            url[writeIndex + 2] = '0';
            break;

        default:
            url[writeIndex] = url[readIndex];
        }
    }
}

int main() {
    char url[] = "http://www.foo.com/In Your Face.html    ";
    URLify(url,36);
    printf("%s\n", url);
    return 0;
}
````
*/

/*: ---
 ## 1.4 Palindrome Permutations: Give a string, write a function to check if it is a permutation of a palindrome.
 A palindrom is a word or phrase that is the same forward and backward. A permutation is a rearrangement of letters. The palindrome does not need to be limited to dictionary words.
 
 *Observations:* Because a palindrome is the same forward and backward, an even-length palindrome must have an even number of each letter, and an odd-length palindrome must have exactly one letter with an odd number of occurrences.
 
 *Plan:*
 * Traverse string, counting characters while doing so.
 * For each character, if it is in the set, remove it. If it is not in the set, add it.
 * If the string is even-length, the set should be empty. If the string is odd-length, there should be only one key in the set
 */
func isPalindrome(_ string: String) -> Bool {
    var characterCount = 0
    var charSet = Set<Character>()

    for char in string.lowercased().characters {
        guard char != " ".characters.first else { continue }

        characterCount += 1

        if charSet.contains(char) {
            charSet.remove(char)
        }
        else {
            charSet.insert(char)
        }
    }

    // For even-length strings, set should contain 0 elements. For odd-length, it should contain 1.
    return (characterCount % 2) == charSet.count
}

isPalindrome("aba")
isPalindrome("abba")
isPalindrome("madam my name is adam")
isPalindrome("Red rum sir is murder")
isPalindrome("tact coa")

/*: ---
 ## 1.5 One Away: There are three types of edits that can be performed on strings: insert a character, remove a character, or replace a character. Given two strings, write a function to check if they are one edit (or zero edits) away.
 
 - Example:
 ```
 pale, ple -> true
 pales, pale -> true
 pale, bale -> true
 pale, bake -> false
 ```
 */

func isOneAway(_ s1: String, _ s2: String) -> Bool {
    switch s1.characters.count - s2.characters.count {
    case 0: // same length
        return processSameLength(s1, s2)

    case -1: // s2 longer than s1
        return processOneAway(longer: s2, shorter: s1)

    case 1: // s1 longer than s2
        return processOneAway(longer: s1, shorter: s2)

    default: // string lengths differ by more than 1
        return false

    }
}

func processSameLength(_ s1: String, _ s2: String) -> Bool {
    var changeFound = false
    var s1Copy = s1
    var s2Copy = s2

    repeat {
        let s1Head = s1Copy.characters.first
        let s2Head = s2Copy.characters.first
        s1Copy = String(s1Copy.characters.dropFirst())
        s2Copy = String(s2Copy.characters.dropFirst())

        guard s1Head != s2Head else { continue }

        // s1Head != s2Head

        if changeFound == true { return false }

        changeFound = true
    } while s1Copy.characters.count > 0

    return true
}

func processOneAway(longer s1: String, shorter s2: String) -> Bool {
    var changeFound = false
    var s1Copy = s1
    var s2Copy = s2

    repeat {
        let s1Head = s1Copy.characters.first
        let s2Head = s2Copy.characters.first
        s1Copy = String(s1Copy.characters.dropFirst())

        guard s1Head != s2Head else {
            s2Copy = String(s2Copy.characters.dropFirst())
            continue
        }
        // s1Head != s2Head

        if changeFound == true { return false }
        changeFound = true
    } while s1Copy.characters.count > 0

    return true
}

isOneAway("pale", "ple")
isOneAway("pale", "ple")
isOneAway("pales", "pale")
isOneAway("pale", "bale")
isOneAway("pale", "bake")
isOneAway("ple", "pale")
isOneAway("abcde", "abc")
isOneAway("abcde", "abcde")
