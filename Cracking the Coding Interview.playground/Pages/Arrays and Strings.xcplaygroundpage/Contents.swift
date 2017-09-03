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
        let s1Head = s1Copy.characters.removeFirst()
        let s2Head = s2Copy.characters.removeFirst()

        guard s1Head != s2Head else { continue }
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
        let s1Head = s1Copy.characters.removeFirst()
        let s2Head = s2Copy.characters.first

        guard s1Head != s2Head else {
            s2Copy.characters.removeFirst()
            continue
        }
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

/*: ---
 ## 1.6 String Compression: Implement a method to perform basic string compression using the coutns of repeated characters. For example, the string `aabcccccaaa` would become `a2b1c5a3`. If the "compressed" string would not become smaller than the original string, return the original string. You can assume the string has only upppercase and lowercase letters (a-z).
 */
func compress(_ str: String) -> String {
    var result = [Character]()
    var previousChar: Character?
    var count = 0

    for char in str.characters {
        if previousChar == nil {
            previousChar = char
            count = 1
            result.append(char)
        }
        else if char == previousChar {
            count += 1
        }
        else { // new character
            result.append(contentsOf: count.description.characters)
            previousChar = char
            count = 1
            result.append(char)
        }
    }

    result.append(contentsOf: count.description.characters)

    if result.count > str.characters.count {
        return str
    }
    else {
        return String(result)
    }
}

compress("abcd")
compress("aabbccdd")
compress("aabcccccaaa")

/*: ---
 ## 1.7 Rotate Matrix: Given an image represented by an NxN matrix, where each pixel in the image is 4 bytes, write a method to roate the image by 90º. Can you do this in place?
 
 - Note: We are going to rotate in layers. We perform a circular rotation on each layer, moving the top edge to the right edige, the right edge to the bottom edge, the bottom edge to the left edge, and the left edge to the top edge. We can do this by copying the top edge to an array, and then move the left to the top, the bottom to the left, and so on. This requires `O(N)` memory, which is actually unnecessary.

    A better way to do this is to implement the swap index by index. In this case, we do the following:
 ```
 for i = 0 to n
    temp = top[i]
    top[i] = left[i]
    left[i] = bottom[i]
    bottom[i] = right[i]
    right[i] = temp
 ```
 
 - Note: We perform such a swap on each layer, starting from the outermost later and working our way inward.

 - Remark: I came up with a solution, but it was inefficient. Below is the solution from the book.
 */
func rotate( _ matrix: inout [[Any]]) -> Bool {
    guard matrix.count != 0, matrix[0].count != 0 else { return false }
    for layer in 0..<(matrix.count / 2) {
        let first = layer
        let last = matrix.count - 1 - layer
        for i in first..<last {
            let offset = i - first
            let top = matrix[first][i]  // save top

            // top = left
            matrix[first][i] = matrix[last-offset][first]

            // left = bottom
            matrix[last-offset][first] = matrix[last][last-offset]

            // bottom = right
            matrix[last][last-offset] = matrix[i][last]

            // right = (save) top
            matrix[i][last] = top
        }
    }

    return true
}

var intMatrix = [
    [1,2,3,4,5,6,7,8],
    [11,12,13,14,15,16,17,18],
    [21,22,23,24,25,26,27,28],
    [31,32,33,34,35,36,37,38],
    [41,42,43,44,45,46,47,48],
    [51,52,53,54,55,56,57,58],
    [61,62,63,64,65,66,67,68],
    [71,72,73,74,75,76,77,78],
]

var tempMatrix = intMatrix as [[Any]]
rotate(&tempMatrix)
intMatrix = tempMatrix as! [[Int]]

var charMatrix = [
    ["A", "B", "C", "D", "E"],
    ["F", "G", "H", "I", "J"],
    ["K", "L", "M", "N", "O"],
    ["P", "Q", "R", "S", "T"],
    ["U", "V", "W", "X", "Y"],
]

tempMatrix = charMatrix as [[Any]]
rotate(&tempMatrix)
charMatrix = tempMatrix as! [[String]]

