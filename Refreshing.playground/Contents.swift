//: ## Refreshing my data structures skills in prep for my interview later today

import Foundation

class DoublyLinkedListNode<Element>: CustomStringConvertible {

    // MARK: Static methods
    static func getHead(_ node: DoublyLinkedListNode<Element>) -> DoublyLinkedListNode<Element> {
        if let previous = node.previous {
            return getHead(previous)
        } else {
            return node
        }
    }

    static func getTail(_ node: DoublyLinkedListNode<Element>) -> DoublyLinkedListNode<Element> {
        if let next = node.next {
            return getTail(next)
        } else {
            return node
        }
    }

    // MARK: - Properties
    let value: Element
    var previous: DoublyLinkedListNode<Element>?
    var next: DoublyLinkedListNode<Element>?

    init(value: Element) {
        self.value = value
    }

    var isHead: Bool {
        return previous == nil
    }

    var isTail: Bool {
        return next == nil
    }

    var length: Int {
        var current = DoublyLinkedListNode.getHead(self)
        var count = 1
        while current.next != nil {
            current = current.next!
            count += 1
        }
        return count
    }

    // MARK: - CustomStringConvertible
    var description: String {
        return String(format: "[DoublyLinkedListNode<\(type(of: Element.self))>] value: \(value), previous: %@, next: %@",
            (previous == nil ? "nil" : "exists"),
            (next == nil ? "nil" : "exists"))
    }
}

struct DoublyLinkedList<Element>: CustomStringConvertible {
    var head: DoublyLinkedListNode<Element>? = nil
    var tail: DoublyLinkedListNode<Element>? = nil
    var length: Int

    init(with node: DoublyLinkedListNode<Element>) {
        head = DoublyLinkedListNode.getHead(node)
        tail = DoublyLinkedListNode.getTail(node)
        length = head?.length ?? 0
    }

    // MARK: - Methods
    // append
    mutating func append(_ node: DoublyLinkedListNode<Element>) {
        guard let tail = tail else {
            head = node
            self.tail = DoublyLinkedListNode.getTail(head!)
            length = head!.length
            return
        }

        length += node.length
        tail.next = node
        node.previous = tail
        self.tail = DoublyLinkedListNode.getTail(node)
    }

    // prepend
    mutating func prepend(_ node: DoublyLinkedListNode<Element>) {
        guard let head = head else {
            self.head = node
            self.tail = DoublyLinkedListNode.getTail(self.head!)
            length = self.head!.length
            return
        }

        length += node.length
        head.previous = DoublyLinkedListNode.getTail(node)
        node.next = head
        self.head = node
    }

    // insert
    mutating func insert(_ node: DoublyLinkedListNode<Element>, after: DoublyLinkedListNode<Element>) {
        length += node.length
        node.previous = after
        DoublyLinkedListNode.getTail(node).next = after.next
        after.next = node
    }

    // remove
    /// Removes just the specified node from the list (i.e., not all subsequent nodes)
    ///
    /// - Parameter node: the node to remove
    mutating func remove(_ node: DoublyLinkedListNode<Element>) {
        if let previous = node.previous {
            previous.next = node.next
        } else { // removing head
            head = node.next
        }

        if let next = node.next {
            next.previous = node.previous
        } else { // removing tail
            tail = node.previous
        }

        length -= 1
    }

    // MARK: - CustomStringConvertible
    var description: String {
        return "[DoublyLinkedList<\(Element.self))>] length: \(length), head: \(head), tail: \(tail)"
    }
}

extension DoublyLinkedList where Element: Comparable {
    mutating func sort() {

    }

}

var list1 = DoublyLinkedList(with: DoublyLinkedListNode(value: "A"))
print("\(list1.head)")
print("\(list1.tail)")
print("\(list1.length)")
print("\(list1.head?.description)")

list1.append(DoublyLinkedListNode(value: "B"))
list1.append(DoublyLinkedListNode(value: "C"))
list1.append(DoublyLinkedListNode(value: "D"))
let eNode = DoublyLinkedListNode(value: "E")
list1.append(eNode)

let xyzNode = DoublyLinkedListNode(value: "X")
var list2 = DoublyLinkedList(with: xyzNode)
list2.append(DoublyLinkedListNode(value: "Y"))
list2.append(DoublyLinkedListNode(value: "Z"))

list1.append(xyzNode)
print("\(list1.description)")
