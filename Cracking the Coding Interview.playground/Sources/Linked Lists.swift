import Darwin
import Foundation

//: # Linked Lists

/*: ---
 Helper methods and data structures
 */

public class ListNode<Element> {
    public var next: ListNode?
    public var value: Element

    public init(value: Element) {
        self.value = value
    }

    public func description() -> String {
        guard next != nil else { return "\(value)" }
        return "\(value), " + next!.description()
    }
}

public func end<T>(of list: ListNode<T>) -> ListNode<T> {
    var runner = list
    while runner.next != nil { runner = runner.next! }
    return runner
}

public func makeIntList(count: Int) -> ListNode<Int> {
    var list = ListNode<Int>(value: Int(arc4random_uniform(UInt32(count + 1))))
    for _ in 1..<count {
        let nextNode = ListNode<Int>(value: Int(arc4random_uniform(UInt32(count + 1))))
        nextNode.next = list
        list = nextNode
    }

    return list
}

public func makeCharacterList(count: Int) -> ListNode<Character> {
    let char = Character(UnicodeScalar(arc4random_uniform(26) + 65)!)
    var list = ListNode<Character>(value: char)
    for _ in 1..<count {
        let nextNode = ListNode<Character>(value: Character(UnicodeScalar(arc4random_uniform(26) + 65)!))
        nextNode.next = list
        list = nextNode
    }

    return list
}

public func makeListFrom(_ string: String) -> ListNode<Character> {
    var list: ListNode<Character>?

    for char in string.characters.reversed() {
        let nextNode = ListNode<Character>(value: char)
        nextNode.next = list
        list = nextNode
    }
    
    return list!
}

public func makeListFrom(_ number: Int) -> ListNode<Int>? {
    var list: ListNode<Int>?
    var num = number

    while num > 0 {
        let digit = num % 10
        let nextNode = ListNode<Int>(value: digit)

        nextNode.next = list
        list = nextNode
        num /= 10
    }

    return list
}

public func makeReversedListFrom(_ number: Int) -> ListNode<Int>? {
    var list: ListNode<Int>?
    var listEnd: ListNode<Int>?
    var num = number

    while num > 0 {
        let digit = num % 10
        if list == nil {
            list = ListNode<Int>(value: digit)
            listEnd = list!
        }
        else {
            listEnd!.next = ListNode<Int>(value: digit)
            listEnd = listEnd!.next
        }

        num /= 10
    }

    return list
}
