import Foundation

//: # Stacks and Queues

/*: ---
 Helper methods and data structures
 */

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
        guard var top = self.top else {
            throw Errors.Empty
        }

        let item = top.data
        top = top.next!
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

public class Queue<T> {
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

    public func add(_ item: T) {
        let node = QueueNode<T>(data: item)
        if last != nil {
            last!.next = node
        }
        last = node
        if first == nil {
            first = last
        }
    }

    public func remove() throws -> T {
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

    public func description() -> String {
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
