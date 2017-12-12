import Foundation

typealias StorageVectorNode<T> = StorageVector<T>.Node<T>
class StorageVector<T> {
    class Node<T> {
        var value: T
        var index: Int?
        var next: Int?
        var previous: Int?

        init(value: T) {
            self.value = value
        }

        var description: String {
            return "index:\(index), next:\(next), previous:\(previous), value:\(value)"
        }
    }

    private(set) var count = 0
    private var filledArray = false
    private let capacity: Int
    private var elements = [Node<T>]()

    private var head: Int?
    private var tail: Int?

    init(capacity: Int) {
        self.capacity = capacity
        elements.reserveCapacity(capacity)
    }

    func addHead(_ value: T) -> Node<T> {
        let node = Node(value: value)
        defer {
            head = node.index
            count += 1
            if count == capacity {
                filledArray = true
            }
        }

        guard let head = self.head else {
            node.index = 0
            tail = node.index
            elements.append(node)
            return node
        }

        if !filledArray && count < capacity {
            node.index = count
            elements.append(node)
        }
        else {
            let last = removeLast()
            node.index = last?.index

            elements[node.index!] = node
        }

        elements[head].previous = node.index
        node.next = head

        return node
    }

    func moveToHead(_ node: Node<T>) {
        guard node.index != head else { return }
        let previous = node.previous
        let next = node.next

        if next != nil {
            elements[next!].previous = previous
        }

        if previous != nil {
            elements[previous!].next = next
        }

        node.next = head
        node.previous = nil

        if head != nil {
            elements[head!].previous = node.index
        }

        if node.index == tail {
            tail = previous
        }

        head = node.index
    }

    func removeLast() -> Node<T>? {
        guard let tail = self.tail else { return nil }
        let previous = elements[tail].previous
        if previous != nil {
            elements[previous!].next = nil
        }
        self.tail = previous

        count -= 1

        if count == 0 {
            head = nil
        }

        return elements[tail]
    }
}

public class LRUCache<Key: Hashable, Value> {

    private struct CachePayload {
        let key: Key
        let value: Value
    }

    private let list: StorageVector<CachePayload>
    private var nodesDict = [Key: StorageVectorNode<CachePayload>]()

    private let capacity: Int

    public init(capacity: Int) {
        self.capacity = max(0, capacity)
        list = StorageVector<CachePayload>(capacity: self.capacity)
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

        if list.count >= capacity {
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
