import Darwin
import Foundation

//: # Linked Lists

/*: ---
 Helper methods and data structures
 */

public class Node<Element> {
    public var next: Node?
    public var value: Element

    public init(value: Element) {
        self.value = value
    }

    public func description() -> String {
        guard next != nil else { return "\(value)" }
        return "\(value), " + next!.description()
    }
}

public func end<T>(of list: Node<T>) -> Node<T> {
    var runner = list
    while runner.next != nil { runner = runner.next! }
    return runner
}

public func makeIntList(count: Int) -> Node<Int> {
    var list = Node<Int>(value: Int(arc4random_uniform(UInt32(count + 1))))
    for _ in 1..<count {
        let nextNode = Node<Int>(value: Int(arc4random_uniform(UInt32(count + 1))))
        nextNode.next = list
        list = nextNode
    }

    return list
}

public func makeCharacterList(count: Int) -> Node<Character> {
    let char = Character(UnicodeScalar(arc4random_uniform(26) + 65)!)
    var list = Node<Character>(value: char)
    for _ in 1..<count {
        let nextNode = Node<Character>(value: Character(UnicodeScalar(arc4random_uniform(26) + 65)!))
        nextNode.next = list
        list = nextNode
    }

    return list
}

public func makeListFrom(_ string: String) -> Node<Character> {
    var list: Node<Character>?

    for char in string.characters.reversed() {
        let nextNode = Node<Character>(value: char)
        nextNode.next = list
        list = nextNode
    }
    
    return list!
}

public func makeListFrom(_ number: Int) -> Node<Int>? {
    var list: Node<Int>?
    var num = number

    while num > 0 {
        let digit = num % 10
        let nextNode = Node<Int>(value: digit)

        nextNode.next = list
        list = nextNode
        num /= 10
    }

    return list
}

public func makeReversedListFrom(_ number: Int) -> Node<Int>? {
    var list: Node<Int>?
    var listEnd: Node<Int>?
    var num = number

    while num > 0 {
        let digit = num % 10
        if list == nil {
            list = Node<Int>(value: digit)
            listEnd = list!
        }
        else {
            listEnd!.next = Node<Int>(value: digit)
            listEnd = listEnd!.next
        }

        num /= 10
    }

    return list
}
