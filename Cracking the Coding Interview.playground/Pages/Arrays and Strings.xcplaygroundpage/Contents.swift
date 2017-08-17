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
 ## 1.3 URLify: Write a method to replace all spaces in a string with '%20'. You may assume that the string has sufficient space at the end to hold the additional characters, and that you are given the "true" length of the string.
 - Note: if implementing in Java, please use a character array so that you can perform this operation in place.
 
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

