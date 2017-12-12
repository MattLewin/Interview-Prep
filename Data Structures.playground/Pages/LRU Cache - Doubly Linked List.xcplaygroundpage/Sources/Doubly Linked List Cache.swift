import Foundation

typealias DoublyLinkedListNode<T> = DoublyLinkedList<T>.Node<T>
class DoublyLinkedList<T> {

    class Node<T> {
        var value: T
        var previous: Node<T>?
        var next: Node<T>?

        init(value: T) {
            self.value = value
        }
    }

    private(set) var count = 0
    private var head: Node<T>?
    private var tail: Node<T>?

    func addHead(_ value: T) -> Node<T> {
        let node = Node(value: value)
        defer {
            head = node
            count += 1
        }

        guard let head = self.head else {
            tail = node
            return node
        }

        head.previous = node
        node.previous = nil
        node.next = head

        return node
    }

    func moveToHead(_ node: Node<T>) {
        guard node !== head else { return }
        let previous = node.previous
        let next = node.next

        next?.previous = previous
        previous?.next = next
        node.next = head
        node.previous = nil
        head?.previous = node

        if node === tail {
            tail = previous
        }

        head = node
    }

    func removeLast() -> Node<T>? {
        guard let tail = self.tail else { return  nil }

        let previous = tail.previous
        previous?.next = nil
        self.tail = previous

        count -= 1

        if count == 0 {
            head = nil
        }

        return tail
    }
}

public class LRUCache<Key: Hashable, Value> {

    private struct CachePayload {
        let key: Key
        let value: Value
    }

    private let list = DoublyLinkedList<CachePayload>()
    private var nodesDict = [Key: DoublyLinkedListNode<CachePayload>]()

    private let capacity: Int

    public init(capacity: Int) {
        self.capacity = max(0, capacity)
    }

    public func setValue(_ value: Value, for key: Key) {
        let payload = CachePayload(key: key, value: value)

        if let node = nodesDict[key] {
            node.value = payload
            list.moveToHead(node)
        }
        else {
            let node = list.addHead(payload)
            nodesDict[key] = node
        }

        if list.count > capacity {
            let nodeRemoved = list.removeLast()
            if let key = nodeRemoved?.value.key {
                nodesDict[key] = nil
            }
        }
    }

    public func getValue(for key: Key) -> Value? {
        guard let node = nodesDict[key] else { return nil }

        list.moveToHead(node)
        return node.value.value
    }
}
