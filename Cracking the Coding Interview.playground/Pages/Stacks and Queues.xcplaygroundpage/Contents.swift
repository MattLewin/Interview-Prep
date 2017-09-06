//: [Previous](@previous)  [Next](@next)
//: ---

//: # Stacks and Queues
import Foundation

/*: ---
 ## 3.1 Three in One: Describe how you could use a single array to implement three stacks
 
 * Callout(Plan): Use an array and a set of three indexes into that array. Each of those indexes will be a top of one of the stacks. Each element of a given stack will be offset from the next element in the stack by 3, thus allowing us three co-existing stacks.
 
 - Note: Looking at the two solutions provided in the book, it seems that the author meant to imply that the array being used for the three stacks is of fixed size. I did not infer that, so I implemented something dynamic. The gist is the same, except that we would need to check for exceeding the predetermined bounds rather than resizing the array.
 */
struct TripleStack { // Could be made generic, but I'm using `Int`s for simplicity
    private var tops = [-3, -2, -1]
    private var s = Array<Int>()

    public enum Errors: Error {
        case Empty(stackNo: Int)
    }
    
    public func isEmpty(stackNo: Int) -> Bool {
        return tops[stackNo] < 0
    }

    public mutating func push(item: Int, to stackNo: Int) {
        tops[stackNo] += 3
        growArray()
        s[tops[stackNo]] = item
    }

    public func peek(stackNo: Int) throws -> Int {
        guard !isEmpty(stackNo: stackNo) else {
            throw Errors.Empty(stackNo: stackNo)
        }

        return s[tops[stackNo]]
    }

    public mutating func pop(stackNo: Int) throws -> Int {
        guard !isEmpty(stackNo: stackNo) else {
            throw Errors.Empty(stackNo: stackNo)
        }

        let item = s[tops[stackNo]]
        tops[stackNo] -= 3
        return item
    }

    public func description() -> String {
        var output = String()
        for stackNo in 1...3 {
            let stackIndex = stackNo - 1
            output += "Stack \(stackNo): "
            var index = tops[stackIndex]
            while index >= 0 {
                output += String(format: "%d, ", s[index])
                index -= 3
            }

            output += "\n"
        }

        return output
    }

    private mutating func growArray() {
        let maxTopIndex = max(tops[0], tops[1], tops[2]) + 1

        // Return if we have enough capacity
        guard s.capacity <= maxTopIndex else {
            return
        }

        // Otherwise, grow the array
        let newSize = maxTopIndex * 2
        let padding = Array(repeating: Int.min, count: newSize)
        s.append(contentsOf: padding)
    }
}

// Populate the three stacks
var triStack = TripleStack()
for i in 1..<5 {
    triStack.push(item: i, to: 0)
    triStack.push(item: i + 10, to: 1)
    triStack.push(item: i * 10 + i, to: 2)
}
triStack.push(item: 999, to: 1)
print(triStack.description())

try triStack.peek(stackNo: 1)
try triStack.pop(stackNo: 1)
do {
    try triStack.pop(stackNo: 0)
    try triStack.pop(stackNo: 0)
    try triStack.pop(stackNo: 0)
    try triStack.pop(stackNo: 0)
    try triStack.pop(stackNo: 0)
} catch TripleStack.Errors.Empty(let stackNo) {
    print("Attempt to pop empty stack \(stackNo)")
}

//: ---
//: [Previous](@previous)  [Next](@next)
