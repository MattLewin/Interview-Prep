import Darwin
import Foundation

//: # Linked Lists

/*: ---
 Helper methods and data structures
 */

public class Node<T: Hashable> {
    public var next: Node?
    public let value: T

    init(value: T) {
        self.value = value
    }

    public func description() -> String {
        guard next != nil else { return "\(value)" }
        return "\(value), " + next!.description()
    }
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

