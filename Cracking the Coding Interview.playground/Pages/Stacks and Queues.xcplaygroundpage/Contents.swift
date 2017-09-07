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

/*: ---
 ## 3.2 Stack Min: How would you design a stack that, in addition to `push` and `pop`, has a function, `min`, that returns the minimum element? `Push`, `pop`, and `min` should all operate in `O(1)` time.
 
 * Callout(Plan):
    A. Include minimum value in stack as part of the element data structure
 
    B. Keep a separate stack for minimums
 
    (A) is good if the stack is not huge. If it *is* huge, we burn an extra `sizeof(item)` for each stack element, when the minimum value may change infrequently
 
    (B) is good if the stack is huge, because we only grow the 'min stack' when we push a new minimum
 
    Let's do (B)
 

 * Callout(Implementation Details):
    - `peek()` should return top value per ususal
    - `push()` should push onto minimum stack if new value is <= top of minimum stack. (Pushing equal so we can pop equal values and still maintain the prior minimum.)
    - `pop()` should pop the minimum stack if existing top.value == minimum
 */
struct StackWithMin<T: Comparable> {
    private var stack = Stack<T>()
    private var minStack = Stack<T>()

    public func peek() throws -> T {
        return try stack.peek()
    }

    public func isEmpty() -> Bool { return stack.isEmpty() }

    public func push(_ item: T) {
        if stack.isEmpty() {
            stack.push(item)
            minStack.push(item)
        }
        else {
            let min = try! minStack.peek()
            if item <= min {
                minStack.push(item)
            }
            stack.push(item)
        }
    }

    public func pop() throws -> T {
        do {
            let item = try stack.pop()
            let min = try minStack.peek()
            if item <= min {
                _ = try! minStack.pop()
            }
            return item
        } catch {
            throw error
        }
    }

    public func min() throws -> T {
        return try minStack.peek()
    }

    public func description() -> String {
        var output = "        Stack: " + stack.description() + "\n"
        output    += "Minimum Stack: " + minStack.description() + "\n"

        return output
    }
}

var stackWithMin = StackWithMin<Int>()

let rangeTop = 5
for i in 1..<rangeTop {
    stackWithMin.push(rangeTop - i + 10)
    stackWithMin.push(rangeTop - i)
    stackWithMin.push((rangeTop - i) * 10 + i)
}
stackWithMin.push(999)

print("\n3.2 Stack with min(): Test 1:")
print(stackWithMin.description())

print("\n3.2 Stack with min(): Test 2:")
print("stackWithMin.min() == 1: \(try! stackWithMin.min() == 1)")

print("\n3.3 Stack with min(): Test 3:")
try print("stackWithMin.pop() == 999: \(stackWithMin.pop() == 999)")

print("\n3.3 Stack with min(): Test 4:")
for _ in 0..<3 {
    try! stackWithMin.pop()
}
try print("stackWithMin.min() == 2: \(stackWithMin.min() == 2)")

print("\n3.3 Stack with min(): Current Stack State:")
print(stackWithMin.description())

/*: ---
 ## 3.3 Stack of Plates: Imagine a literal stack of plates. If the stack gets too high, it might topple. Therefore, in real life, we would likely start a new stack when the previous stack exceeds some threshold. Implement a data structure, `SetofStacks` that mimics this. `SetOfStacks` should be composed of several stacks and should create a new stack once the previous one exceeds capacity. `SetOfStacks.push()` and `SetOfStacks.pop()` should behave identically to a single stack. (That is, `pop()` should return the same values as if there were just a single stack.)
 
 * Callout(Follow Up): Implement a function `popAt(int index)` that performs a pop operation on a specific substack.
 

 * Callout(Plan):
    - Data structure needs one or more stacks => array, list, or stack of substacks. 
        - The stack of substacks is out, because `popAt` will be unreasonably difficult to implement with a stack of substacks.
        - A linked list allows us to harvest empty stack nodes versus keeping around unused array elements. Each empty stack in an array, though, will consume almost no memory. Thus, we are going with an array.

    - Initializer needs a threshold parameter
 
    - Data structure must contain a count of elements in each stack => a substack structure
 
 
 * Callout(Implementation Details):
    - `Substack`: element count, stack
    - `SetOfStacks`: array of substacks, threshold, current stack num
    - `pop()`  : when last element of current substack is popped, decrement current stack num. Don't go below 0
    - `push()` : if current substack's element count equals threshold, append empty stack to array
    - `popAt()`: simply index the stack array
 */
struct SetOfStacks<T> {
    class Substack<T> {
        var count = 0
        var stack = Stack<T>()

        func description(indentation: Int = 0) -> String {
            let indent = String(repeating: "  ", count: indentation)
            var output = indent + "[\n"
            output += indent + "  count: \(count)\n"
            output += indent + "  stack: \(stack.description())\n"
            output += indent + "]\n"
            return output
        }
    }

    var allStacks = [Substack<T>()]
    let threshold: Int
    var currentStack = 0

    public init(threshold: Int) {
        self.threshold = threshold
    }

    public func isEmpty() -> Bool {
        return allStacks[0].stack.isEmpty()
    }

    public func peek() throws -> T {
        guard !allStacks[0].stack.isEmpty() else { throw Stack<T>.Errors.Empty }
        return try! allStacks[currentStack].stack.peek()
    }

    public mutating func push(_ item: T) {
        if allStacks[currentStack].count == threshold { addStack() }

        let substack = allStacks[currentStack]
        substack.stack.push(item)
        substack.count += 1
    }

    public mutating func pop() throws -> T {
        guard !allStacks[0].stack.isEmpty() else { throw Stack<T>.Errors.Empty }

        let substack = allStacks[currentStack]
        let item = try! substack.stack.pop()
        substack.count -= 1
        if substack.count == 0 && currentStack != 0 {
            currentStack -= 1
        }

        return item
    }

    public mutating func popAt(substack: Int) throws -> T {
        guard substack <= currentStack, !allStacks[substack].stack.isEmpty() else {
            throw Stack<T>.Errors.Empty
        }

        let substack = allStacks[substack]
        let item = try! substack.stack.pop()
        substack.count -= 1
        return item
    }

    private mutating func addStack() {
        currentStack += 1
        if allStacks.count <= currentStack {
            allStacks.append(Substack<T>())
        }
    }

    public func description() -> String {
        var output = "[\n"
        output += "  threshold:\(threshold)\n"
        output += "  currentStack:\(currentStack)\n"
        output += "  allStacks:\n"
        for i in 0...currentStack {
            output += allStacks[i].description(indentation: 1)
        }
        output += "]\n"
        return output
    }
}

print("---------- 3.3 Stack of Plates ----------")

var plates = SetOfStacks<Int>(threshold: 5)

for i in 0..<5 {
    plates.push(i)
    plates.push(i + 10)
    plates.push(i * 10 + i)
}
plates.push(999)
print("plates:")
print(plates.description())

print("plates.peek() = \(try! plates.peek())")
print("plates.isEmpty() = \(plates.isEmpty())")
print("plates.pop() = \(try! plates.pop())")
print("plates.popAt(substack: 1) = \(try! plates.popAt(substack: 1))")
print("plates.pop() = \(try! plates.pop())")
print("plates:")
print(plates.description())
print("popping plates until empty")
var output = "["
repeat {
    output += "\(try! plates.pop()) "
} while !plates.isEmpty()
output += "]"
print(output)
print("plates:")
print(plates.description())
print("plates.isEmpty() = \(plates.isEmpty())")
do {
    print("plates.pop() (should fail) = \(try plates.pop())")
} catch {
    print("plates.pop() failed. error: \(error)")
}

//: ---
//: [Previous](@previous)  [Next](@next)
