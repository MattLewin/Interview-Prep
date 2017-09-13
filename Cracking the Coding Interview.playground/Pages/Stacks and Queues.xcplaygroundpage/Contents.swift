//: [Previous](@previous)  [Next](@next)
//: ---

//: # Stacks and Queues
import Darwin // for arc4random()
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

    public mutating func peek() throws -> T {
        return try stack.peek()
    }

    public func isEmpty() -> Bool { return stack.isEmpty() }

    public mutating func push(_ item: T) {
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

    public mutating func pop() throws -> T {
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

/*: ---
 ## 3.4 Queue via Stacks: Implement `MyQueue`, which implements a queue using two stacks.
 
 * Callout(Plan): The FIFO nature of a queue can be implemented by having "tail" and "head" stacks. When `enqueu`ing, we push the new element onto the "tail" stack. This means the first-in element will always be at the bottom of that stack. When `dequeu`ing, we `pop()` the top element of the "head" stack. If that stack is empty, we "move" the "tail" stack to the "head" stack. "Move" in this context means `pop`ping each element from the "tail" stack and `push`ing it onto the "head" stack. This will leave the "head" stack with the elments `pop`able in FIFO order.
 */
struct MyQueue<T> {
    var headStack = Stack<T>() // dequeue ops
    var tailStack = Stack<T>() // enqueue ops

    public enum Errors: Error {
        case Empty  // dequeue() called on empty queue
    }

    public mutating func enqueue(_ item: T) {
        tailStack.push(item)
    }

    public mutating func dequeue() throws -> T {
        if headStack.isEmpty() {
            guard !tailStack.isEmpty() else {
                throw Errors.Empty
            }
            moveTailToHead()
        }

        return try! headStack.pop()
    }

    public func isEmpty() -> Bool {
        return headStack.isEmpty() && tailStack.isEmpty()
    }

    fileprivate mutating func moveTailToHead() {
        repeat {
            headStack.push(try! tailStack.pop())
        } while !tailStack.isEmpty()
    }
}

print("\n\n---------- 3.4 Queue via Stacks ----------\n")

var myQ = MyQueue<Int>()
for i in (0..<3).reversed() {
    myQ.enqueue(i)
}
print("o queue with three elements: " + String(describing: myQ))
print("o myQ.dequeue() == 2: \(try! myQ.dequeue() == 2)")
print("o queue with head element removed: " + String(describing: myQ))

for i in (0..<5).reversed() {
    myQ.enqueue(i * 10 + i / 2)
}

print("o queue with five new elements (notice 'tailStack'): " + String(describing: myQ))

_ = try! myQ.dequeue()
_ = try! myQ.dequeue()
print("o queue with first two elements dequeued: " + String(describing: myQ))
print("o myQ.dequeue() == 42: \(try! myQ.dequeue() == 42)")
print("o queue with next element dequeued: " + String(describing: myQ))


/*: ---
 ## 3.5 Sort Stack: write a program to sort a stack such that the smallest items are on top. You can use a temporary stack, but no other data structure (i.e., an array). The stack should support `push`, `pop`, `peek`, and `isEmpty`.
 
 * Callout(Plan): When pushing a new value, we need to ensure the new value is placed beneath any lesser values and above any greater
    values. => popping elements and pushing them onto a temporary stack until we reach a value greater than or equal to our new item.
 
    In addition, to make things more efficient, we only need to "consolidate" the two stacks when we want to `pop` or `peek`.
 

 * Callout(Implementation Details for `push`):
    1. While the sorted stack is not empty, compare new item to `top` of storted stack
    2. if `item` > than `top`, pop sorted and push to minimums stack, and then continue the loop
    3. if `item` == `top`, push it onto the sorted stack
    4. if `item` < `top`, while minimums stack is not empty, compare to `top` of minimums stack
        1. if `item` >= `top`, push onto sorted stack and exit
        2. if `item` < `top`, pop minimums stack and push that onto the sorted stack, and then return to (4)
        3. if minimums stack empty, push `item` onto sorted and exit
    5. if sorted stack is empty, push `item` onto sorted stack
 */
struct SortedStack<T: Comparable> {
    var sortedStack = Stack<T>()
    var minsStack = Stack<T>()

    public enum Errors: Error {
        case Empty // Attempted to peek or pop an empty stack
    }

    public func isEmpty() -> Bool {
        return sortedStack.isEmpty() && minsStack.isEmpty()
    }

    fileprivate mutating func consolidateStacks() {
        while !minsStack.isEmpty() {
            sortedStack.push(try! minsStack.pop())
        }
    }

    public mutating func peek() throws -> T {
        consolidateStacks()
        guard !sortedStack.isEmpty() else {
            throw Errors.Empty
        }
        return try! sortedStack.peek()
    }

    public mutating func pop() throws -> T {
        consolidateStacks()
        guard !sortedStack.isEmpty() else {
            throw Errors.Empty
        }
        return try! sortedStack.pop()
    }

    public mutating func push(_ item: T) {
        while !sortedStack.isEmpty() {
            let sortedTop = try! sortedStack.peek()
            switch item {
            case _ where item > sortedTop:
                minsStack.push(try! sortedStack.pop())

            case _ where item == sortedTop:
                sortedStack.push(item)
                return

            case _ where item < sortedTop: // check minsStack
                while !minsStack.isEmpty() {
                    let minsTop = try! minsStack.peek()
                    switch item {
                    case _ where item >= minsTop:
                        sortedStack.push(item)
                        return

                    case _ where item < minsTop:
                        sortedStack.push(try! minsStack.pop())

                    default: break // we can never get here
                    }
                }
                sortedStack.push(item)
                return

            default: break // we can never get here
            }
        }
        sortedStack.push(item)
    }
}

print("\n\n---------- 3.5 Sorted Stack ----------\n")
var ss = SortedStack<Character>()
print("Testing SortedStack using the characters in the string, \"STACK\"")
print("SortedStack: \(String(describing: ss))")
for char in "STACK".characters {
    ss.push(char)
    print("pushed \(char). SortedStack: \(String(describing: ss))")
}
print("Peeking at sorted stack: \(try! ss.peek())")
print("SortedStack: \(String(describing: ss))")

ss = SortedStack<Character>()
print("\nTesting SortedStack using the characters in the string, \"ABDCE\"")
print("SortedStack: \(String(describing: ss))")
for char in "ABDCE".characters {
    ss.push(char)
    print("pushed \(char). SortedStack: \(String(describing: ss))")
}
print("Peeking at sorted stack: \(try! ss.peek())")
print("SortedStack: \(String(describing: ss))")

/*: ---
 ## 3.5 (redux): I misread the problem. The challenge was to sort an (unsorted) stack using at most one other stack. I've already looked at the answer, so I don't know what I would have come up with. Here's what the book provides.
 
 * Callout(Plan): We will build a stack sorted from highest to lowest, and then reverse it by putting it back into the original stack
    1. Pop the top of the unsorted stack, `s1`, and store that value in a temporary variable
    2. Find the correct place in the sorted stack, `s2`, to store this value. The correct place is above the first element less than it.
    3. Finding the correct place, requires us to pop `s2` until it's either empty, or we find a value less than the element we are pushing. We push all these popped values onto `s1` temporarily.
    4. Push our temp value onto `s2`
    5. Repeat until `s1` is empty
    6. Reverse `s2` by popping each element and pushing it into `s1`
 
 * Complexity: `O(N^2)` time and `O(N)` space
 */
func sort<T:Comparable>(_ s1: inout Stack<T>) {
    var s2 = Stack<T>()
    while !s1.isEmpty() {
        // Insert each element in s1 in sorted order into s2.
        let tmp = try! s1.pop()
        while !s2.isEmpty() && (try! s2.peek() > tmp) {
            s1.push(try! s2.pop())
        }
        s2.push(tmp)
    }

    // Copy the elements from s2 back to s1
    while !s2.isEmpty() {
        s1.push(try! s2.pop())
    }
}

print("\n\n---------- 3.5 (redux) Sort a Stack ----------\n")
var stackToSort = Stack<Character>()
print("testing sort(:) with the characters in the string, \"STACK\"")
for char in "STACK".characters {
    stackToSort.push(char)
}
print("unsorted stackToSort: \(String(describing: stackToSort))")
sort(&stackToSort)
print("  sorted stackToSort: \(String(describing: stackToSort))")

print("")

stackToSort = Stack<Character>()
print("testing sort(:) with the characters in the string, \"ABDCE\"")
for char in "ABDCE".characters {
    stackToSort.push(char)
}
print("unsorted stackToSort: \(String(describing: stackToSort))")
sort(&stackToSort)
print("  sorted stackToSort: \(String(describing: stackToSort))")


/*: ---
 ## 3.6 Animal Shelter: A shelter operates on a FIFO basis, taking in dogs and cats. A human can request the oldest pet, oldest dog,
    or oldest cat. Implement `dequeueCat`, `dequeueDog`, `dequeueAny`, and `enqueue`. You can use the built-in `LinkedList`. (But,
    this not being Java, we don't have such a thing.)
 
 * Callout(Initial Thoughts):
    - two linked lists, one for dogs, one for cats
    - enclosing data structure keeps a counter of animals taken in
    - each animal has a "priority" that is the counter when it was brought in
    - keep head and tail pointers for enqueue and dequeue
    - `dequeueCat` removes and returns head of that queue, dog the same
    - `dequeueAny` removes and returns the one with the smallest priority value
 
 */
struct Animal: CustomStringConvertible {
    enum Species {
        case Cat
        case Dog
    }

    let name: String
    let species: Species

    var description: String {
        return "\(name):\(species)"
    }

    init(species: Species) {
        switch species {
        case .Cat:
            name = "Felix-\(Int(arc4random()))"

        case .Dog:
            name = "Phydeaux-\(Int(arc4random()))"
        }
        self.species = species
    }
}

struct AnimalShelter: CustomStringConvertible {
    class ListNode: CustomStringConvertible {
        let animal: Animal
        let priority: Int
        var next: ListNode?

        init(animal: Animal, priority: Int) {
            self.animal = animal
            self.priority = priority
        }

        var description: String {
            let thisAnimal = "\(animal)(\(priority))"
            guard next != nil else { return thisAnimal }
            return "\(thisAnimal) " + next!.description
        }
    }

    public enum Errors: Error {
        case NoAnimals
    }

    var intakeCount = 0
    var dogs: ListNode?
    var cats: ListNode?
    var dogsTail: ListNode?
    var catsTail: ListNode?

    public mutating func enqueue(_ stray: Animal) {
        let newNode = ListNode(animal: stray, priority: intakeCount)
        intakeCount += 1

        switch stray.species {
        case .Cat:
            guard catsTail != nil else {
                catsTail = newNode
                cats = catsTail
                return
            }

            catsTail!.next = newNode
            catsTail = newNode

        case .Dog:
            guard dogsTail != nil else {
                dogsTail = newNode
                dogs = dogsTail
                return
            }

            dogsTail!.next = newNode
            dogsTail = newNode
        }
    }

    public mutating func dequeueAny() throws -> Animal {
        guard cats != nil, dogs != nil else { throw Errors.NoAnimals }

        if cats == nil {
            return try! dequeueDog()
        }
        else if dogs == nil {
            return try! dequeueCat()
        }

        if cats!.priority < dogs!.priority {
            return try! dequeueCat()
        }
        else {
            return try! dequeueDog()
        }
    }

    public mutating func dequeueCat() throws -> Animal {
        guard let catNode = cats else {
            throw Errors.NoAnimals
        }

        cats = catNode.next
        return catNode.animal
    }

    public mutating func dequeueDog() throws -> Animal {
        guard let dogNode = dogs else {
            throw Errors.NoAnimals
        }

        dogs = dogNode.next
        return dogNode.animal
    }

    var description: String {
        let dogsDesc = "Dogs: [ \(String(describing: dogs)) ]"
        let catsDesc = "Cats: [ \(String(describing: cats)) ]"
        return "\(dogsDesc), \(catsDesc)"
    }
}

print("\n\n---------- 3.6 Animal Shelter ----------\n")
var shelter = AnimalShelter()
for _ in 0..<5 {
    switch Int(arc4random_uniform(2)) {
    case 0:
        shelter.enqueue(Animal(species: .Dog))
        shelter.enqueue(Animal(species: .Cat))

    case 1:
        shelter.enqueue(Animal(species: .Cat))
        shelter.enqueue(Animal(species: .Dog))

    default: break // will never get here
    }
}

print("Shelter Population: \(String(describing: shelter))")
print("dequeueAny(): \(try! shelter.dequeueAny())")
print("dequeueCat(): \(try! shelter.dequeueCat())")
print("dequeueDog(): \(try! shelter.dequeueDog())")

//: ---
//: [Previous](@previous)  [Next](@next)
