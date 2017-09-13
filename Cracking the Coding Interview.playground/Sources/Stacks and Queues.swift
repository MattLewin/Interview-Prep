import Foundation

//: # Stacks and Queues

/*: ---
 Helper methods and data structures
 */

public struct Stack<Element>: CustomStringConvertible {
    var items = [Element]()

    public init() { }

    public enum Errors: Error {
        case Empty // Tried to pop empty stack
    }

    public mutating func pop() throws -> Element {
        guard items.count > 0 else { throw Errors.Empty }
        return items.removeLast()
    }

    public mutating func push(_ item: Element) {
        items.append(item)
    }

    public func isEmpty() -> Bool {
        return items.count == 0
    }

    public func peek() throws -> Element {
        guard items.count > 0 else { throw Errors.Empty }
        return items.last!
    }

    public var description: String {
        guard items.count > 0 else { return "Empty" }
        var first = true
        var output = "["

        for item in items.reversed() {
            if !first {
                output += ", "
            }
            else {
                first = false
            }

            output += String(describing: item)
        }

        output += "]"
        return output
    }
}

/*
public class Stack<T> {

    fileprivate class StackNode<T> {
        var data: T
        var next: StackNode<T>?

        init(data: T) {
            self.data = data
        }
    }

    public init() { }

    public enum Errors: Error {
        case Empty // Tried to pop empty stack
    }

    private var top: StackNode<T>?

    public func pop() throws -> T {
        guard let currentTop = self.top else {
            throw Errors.Empty
        }

        let item = currentTop.data
        top = currentTop.next

        return item
    }

    public func push(_ item: T) {
        let newTop = StackNode<T>(data: item)
        newTop.next = top
        top = newTop
    }

    public func peek() throws -> T {
        guard let top = self.top else {
            throw Errors.Empty
        }

        return top.data
    }

    public func isEmpty() -> Bool {
        return top == nil
    }

    public func description() -> String {
        var output = "["
        var node = top
        var first = true

        guard !isEmpty() else {
            return "Empty"
        }

        while node != nil {
            if !first {
                output += ", "
            }
            else {
                first = false
            }

            output += String(describing: node!.data)
            node = node!.next
        }

        output += "]"
        return output
    }
}
*/

public class Queue<T>: CustomStringConvertible {
    fileprivate class QueueNode<T> {
        var data: T
        var next: QueueNode<T>?

        init(data: T) {
            self.data = data
        }
    }

    public enum Errors: Error {
        case NoSuchElement // Tried to reference an empty queue
    }

    public init() { }
    
    private var first: QueueNode<T>?
    private var last: QueueNode<T>?

    public func enqueue(_ item: T) {
        let node = QueueNode<T>(data: item)
        if last != nil {
            last!.next = node
        }
        last = node
        if first == nil {
            first = last
        }
    }

    public func dequeue() throws -> T {
        guard let head = self.first else {
            throw Errors.NoSuchElement
        }

        let data = head.data
        first = head.next
        if first == nil {
            last = nil
        }
        return data
    }

    public func peek() throws -> T {
        guard let first = self.first else {
            throw Errors.NoSuchElement
        }

        return first.data
    }

    public func isEmpty() -> Bool {
        return first == nil
    }

    public var description: String {
        guard first != nil else {
            return "Empty"
        }

        var output = "["
        var runner = first

        while runner != nil {
            output += String(describing: runner!.data)

            if runner !== last {
                output += ", "
            }

            runner = runner!.next
        }

        output += "]"
        return output
    }
}
