//: [Previous](@previous)
//: ---

import Foundation

//: # Linked Lists

/*: ---
 ## 2.1 Remove Dups: Write an algorithm to remove duplicate elements from an unsorted linked list
 */

class Node<T: Hashable> {
    var next: Node?
    let value: T

    func description() -> String {
        guard next != nil else { return "value:\(value)" }
        return "value:\(value)\n" + next!.description()
    }

    init(value: T) {
        self.value = value
    }
}

func removeDups<T: Hashable>(from list: Node<T>) {
    var uniques = Set<T>()
    var currentNode = list

    uniques.insert(currentNode.value)

    while currentNode.next != nil {
        let nextNode = currentNode.next!
        if uniques.contains(nextNode.value) {
            currentNode.next = nextNode.next!
        }
        else {
            uniques.insert(nextNode.value)
            currentNode = nextNode
        }
    }
}

var list1 = Node(value: 1)
var node2 = Node(value: 2)
node2.next = list1
list1 = node2

node2 = Node(value: 3)
node2.next = list1
list1 = node2

node2 = Node(value: 4)
node2.next = list1
list1 = node2

node2 = Node(value: 3)
node2.next = list1
list1 = node2

//print(list1.description())

removeDups(from: list1)
print(list1.description())

//: **Follow up:** how would you solve this problem if a temporary buffer is not allowed?

func removeDupsNoBuffer<T: Hashable>(from list: Node<T>) {
    var currentNode = list

    while currentNode.next != nil {
        var runner = currentNode.next!
        if runner.value == currentNode.value {
            currentNode.next = runner.next
        }
        else {
            while runner.next != nil {
                if runner.next!.value == currentNode.value {
                    runner.next = runner.next!.next
                }
                else {
                    runner = runner.next!
                }
            }
        }

        currentNode = currentNode.next!
    }
}

list1 = Node(value: 1)
node2 = Node(value: 2)
node2.next = list1
list1 = node2

node2 = Node(value: 3)
node2.next = list1
list1 = node2

node2 = Node(value: 4)
node2.next = list1
list1 = node2

node2 = Node(value: 3)
node2.next = list1
list1 = node2

removeDupsNoBuffer(from: list1)
print(list1.description())


