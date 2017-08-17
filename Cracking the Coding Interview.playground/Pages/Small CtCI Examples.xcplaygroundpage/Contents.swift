//: [Previous](@previous)

//: # Small examples from Cracking the Coding Interview

import Foundation


//: ## Unnecessary work (p. 68)
//: - Example: Print all positive integer solutions to the equation `a^3 + b^3 = c^3 + d^3`
let n = 100

//: - Note: The three solutions below are commented out because they are so inefficient
/*:
 A brute force solution will just have four nested `for` loops

    for a in 1...n {
        for b in 1...n {
            for c in 1...n {
                for d in 1...n {
                    if (pow(Decimal(a), 3) + pow(Decimal(b), 3)) == (pow(Decimal(c), 3) + pow(Decimal(d), 3)) {
                        print("\(a)^3 + \(b)^3 = \(c)^3 + \(d)^3")
                    }
                }
            }
        }
    }
*/

/*:
 Only one value of `d^3` could work, so we should break after finding it

    for a in 1...n {
        for b in 1...n {
            for c in 1...n {
                for d in 1...n {
                    if (pow(Decimal(a), 3) + pow(Decimal(b), 3)) == (pow(Decimal(c), 3) + pow(Decimal(d), 3)) {
                        print("\(a)^3 + \(b)^3 = \(c)^3 + \(d)^3")
                        break
                    }
                }
            }
        }
    }
*/

/*:
 If there is only one valid `d` value, we should just compute it. It's simply the cube root of `a^3 + b^3 - c^3`. This reduces our complexity from `O(N^4)` to `O(N^3)`

    for a in 1...n {
        for b in 1...n {
            for c in 1...n {
                let abc = pow(Double(a), 3) + pow(Double(b), 3) - pow(Double(c), 3)
                let d = Decimal(pow(abc, 1/3))
                if (pow(Double(a), 3) + pow(Double(b), 3)) == (pow(Double(c), 3) + pow(Double(d), 3)),
                    0 <= d,
                    d <= n {
                    print("\(a)^3 + \(b)^3 = \(c)^3 + \(d)^3")
                }
            }
        }
    }
*/

//: ## Duplicated work (pp. 68-69)
/*:
 Using the same problem and brute force algorithm as above, let's look for duplicated work this time.
 
 The algorithm operates by essentially iterating through all `(a, b)` pairs and then searching all `(c, d)` pairs to find if there are any matches to that `(a, b)` pair.
 
 Why do we keep compuing all `(c, d)` pairs for each `(a, b)` pair? We should just create the list of `(c, d)` pairs once. Then, when we have an `(a, b)` pair, find the matches within the `(c, d)` list. We can quickly locate the matches by inserting each `(c, d)` pair into a hash table that maps from the sum to the pair (or, rather, the list of pairs that have that sum).
 
 */

var cdValueMap = [Decimal: [(Int, Int)]]()

for c in 1...n {
    for d in 1...n {
        let result = pow(Decimal(c), 3) + pow(Decimal(d), 3)
        guard var list = cdValueMap[result] else {
            cdValueMap[result] = [(c, d)]
            continue
        }

        list.append((c, d))
    }
}

for a in 1...n {
    for b in 1...n {
        let result = pow(Decimal(a), 3) + pow(Decimal(b), 3)
        guard let list = cdValueMap[result] else { continue }
        for (c, d) in list {
            print("\(a)^3 + \(b)^3 = \(c)^3 + \(d)^3")
        }
    }
}

/*:
 Actually, once we have the map of all the `(c, d)` pairs, we can just use that directly. We don't need to generate the `(a, b)` pairs. Each `(a, b)` pair will already be in `cdValueMap`.
 */

print("###################")

for (result, list) in cdValueMap {
    for (a, b) in list {
        for (c, d) in list {
            print("\(a)^3 + \(b)^3 = \(c)^3 + \(d)^3")
        }
    }
}

//: ## Optimize & Solve Technique #4: Base Case and Build (p. 71)
/*:
 With Base Case and Build, we solve the problem first for a base case (e.g., `n = 1`) and then try to build up from there. When we get to more complex/interesting cases (often `n = 3` or `n = 4`), we try to build those using the prior solutions.

 - Example: Design an algorithm to print all permutions of a string. For simplicity, assume all characters are unique.

 Consider a test string of `abcdefg`.

 - Note: The algorithm below runs in `O(N!)` time. It's *slow*.
 */

let testString = "abcdefg"

func allPermutations(of testString: String) -> [String] {

    let characters = testString.characters

    if testString.characters.count == 1 {
        return [testString]
    }

    let substring = String(characters.dropLast())
    let lastCharacter = characters.last!
    let subStringPermutations = allPermutations(of: substring)

    var permutations = [String]()
    for word in subStringPermutations {
        var wordCharacters = String(word.characters).characters

        for index in wordCharacters.indices {
            var wordCharactersCopy = wordCharacters
            wordCharactersCopy.insert(lastCharacter, at: index)
            permutations.append(String(wordCharactersCopy))
        }

        wordCharacters.append(lastCharacter)
        permutations.append(String(wordCharacters))
    }

    return permutations
}

let permutations = allPermutations(of: testString)
print("\(permutations.count) permutations of '\(testString)': \(permutations)")

//: [Next](@next)
