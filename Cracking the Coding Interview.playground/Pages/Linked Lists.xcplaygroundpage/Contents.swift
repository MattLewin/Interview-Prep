//: [Previous](@previous)

/*: ---
 ## 2.1 Remove Dups: Write an algorithm to remove duplicate elements from an unsorted linked list
 */
func removeDups<T: Hashable>(from list: Node<T>) {
    var uniques = Set<T>()
    var currentNode = list

    uniques.insert(currentNode.value)

    while currentNode.next != nil {
        let nextNode = currentNode.next!
        guard nextNode.next != nil else { return }
        if uniques.contains(nextNode.value) {
            currentNode.next = nextNode.next!
        }
        else {
            uniques.insert(nextNode.value)
            currentNode = nextNode
        }
    }
}

var intList = makeIntList(count: 4)

print(intList.description())

removeDups(from: intList)
print(intList.description())

//: **Follow up:** how would you solve this problem if a temporary buffer is not allowed?

func removeDupsNoBuffer<T: Hashable>(from list: Node<T>) {
    var currentNode = list

    while currentNode.next != nil {
        var runner = currentNode.next!
        guard runner.next != nil else { return }
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

intList = makeIntList(count: 6)

print(intList.description())
removeDupsNoBuffer(from: intList)
print(intList.description())

let charList = makeCharacterList(count: 15)
print(charList.description())
removeDups(from: charList)
print(charList.description())

let strList = makeListFrom("ABCDEFG")
print(strList.description())

/*: ---
 ## 2.2 Return Kth to last element: implement an algorithm to find the Kth to last element of a singly-linked list
 
 * Callout(Plan): Create two pointers, `seeking` and `trailing`, pointing at the head of the list. Walk `seeking` through the list until it reaches the `K`th element of the list. Walk both `seeking` and `trailing` until `seeking` reaches the end of the list. Return the element `trailing` points at.
 */
func findElement<T: Hashable>(k: Int, fromEndOf list: Node<T>) -> Node<T>? {
    var seeking = list
    var trailing = list

    for _ in 0..<k {
        guard seeking.next != nil else { return nil }

        seeking = seeking.next!
    }

    while seeking.next != nil {
        seeking = seeking.next!
        trailing = trailing.next!
    }

    return trailing
}

let element = findElement(k: 3, fromEndOf: strList)
print("element=\(element?.value ?? "0")")



//: ---
//: [Previous](@previous)  [Next](@next)