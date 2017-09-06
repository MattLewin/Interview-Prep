//: [Previous](@previous)
//: ---
//: # Linked Lists
import Foundation


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

/*: ---
 ## 2.3 Delete Middle Node: Implement an algorithm to delete a node in the middle (i.e., any node but the first and last nodes, not necessarily the exact middle) of a singly linked list, given only access to that node.
 
 ```
 Input: the node c from the linked list a->b->c->d->e->f
 Result: nothing is returned, but the new linked list is a->b->d->e->f
 ```
 
 * Callout(Plan): Since we can access our successor but not our predecessor, we replace `value` and `next` in this node with those in our successor.
 */
func delete<T: Hashable>(_ node: Node<T>) {
    guard let nextNode = node.next else { return }
    node.value = nextNode.value
    node.next = nextNode.next
}

let deleteTestList = makeListFrom("ABCDEF")
let cNode = deleteTestList.next!.next!
delete(cNode)
print(deleteTestList.description())

/*: ---
 ## 2.4 Partition a linked list around a value `X` such that all values less than `X` come before all values greater than or equal to `X`. Numbers larger than `X` can come before `X`, as long as no smaller numbers come before any number `X` or greater.
 
 * Callout(Plan): walk the list until we encounter a number `X` or greater. Keep a reference, `target`, to that element, and increment the other pointer until we find a number less than `X`. Swap the two values. Increment `target` to the next element. Traverse with the second pointer until we either find a number less than `X` or reach the end of the list. Each time we find a number less than `X`, swap it with `target` element and increment `target`.
 
 - Note: The solution below is unlike the two solutions offered in the book, but it is a legitimate solution that uses O(N) storage and takes O(N) time.
*/
func partition<T: Hashable & Comparable>(_ list: Node<T>, by x: T) {
    var seeker: Node<T>? = list

    // find first value >= X in list
    while seeker != nil, seeker!.value < x {
        seeker = seeker!.next
    }

    guard seeker != nil else { return }
    var target = seeker!

    // find next value less than x
    while seeker != nil {
        if seeker!.value >= x {
            seeker = seeker!.next
            continue
        }

        // found value to swap
        let temp = target.value
        target.value = seeker!.value
        seeker!.value = temp
        target = target.next!
        seeker = seeker!.next
    }
}

var partitionList = makeListFrom("ABCDCEFABGHC")
print("list to partition: \(partitionList.description())")
partition(partitionList, by: "C")
print("partition by 'C' : \(partitionList.description())")

partitionList = makeListFrom("ABCDCEFABGHC")
partition(partitionList, by: "E")
print("partition by 'E' : \(partitionList.description())")

partitionList = makeListFrom("ABCDCEFABGHC")
partition(partitionList, by: "B")
print("partition by 'B' : \(partitionList.description())")

partitionList = makeListFrom("ABCDCFFABGHC")
print("list w/o X value : \(partitionList.description())")
partition(partitionList, by: "E")
print("partition by 'E' : \(partitionList.description())")

/*: ---
 ## 2.5 Sum Lists: You have two numbers represented by a linked list, where each node contains a single digit. The digits are stored in *reverse* order, such that the 1's digit is at the head of the list. Write a function that adds the two numbers and returns the sum as a linked list.
 
 - Example:
    Input: (7 -> 1 -> 6) + (5 -> 9 -> 2). That is, 617 + 295.
 
    Output: (2 -> 1 -> 9). That is, 912.
 */
func sumReversedLists(_ list1: Node<Int>, _ list2: Node<Int>) -> Node<Int>? {
    var runner1: Node<Int>? = list1
    var runner2: Node<Int>? = list2
    var result: Node<Int>?
    var resultEnd: Node<Int>?
    var carryTheOne: Int = 0

    while runner1 != nil || runner2 != nil {
        var sum = carryTheOne
        if runner1 != nil {
            sum += runner1!.value
            runner1 = runner1!.next
        }

        if runner2 != nil {
            sum += runner2!.value
            runner2 = runner2!.next
        }

        carryTheOne = sum / 10
        sum %= 10

        if result == nil { // first time through
            result = Node<Int>(value: sum)
            resultEnd = result
        }
        else {
            resultEnd!.next = Node<Int>(value: sum)
            resultEnd = resultEnd!.next
        }
    }

    if carryTheOne == 1 {
        resultEnd!.next = Node<Int>(value: 1)
    }

    return result
}

var sumList1 = makeReversedListFrom(617)!
var sumList2 = makeReversedListFrom(295)!
let sumResult = sumReversedLists(sumList1, sumList2)!
print("(\(sumList1.description())) + (\(sumList2.description())) = (\(sumResult.description()))")

/*:
 ## FOLLOW UP

 Suppose the digits are stored in forward order. Repeat the above problem.
 */

//: Skipping this for now, because it's annonyingly cumbersome. I would do it using recursion and passing the remainder along.


/*: ---
 ## 2.6 Palindrome: Implement a function to check if a linked list is a palindrome
 
 * Callout(Plan):
    1. traverse list, counting nodes and building a new list by prepending erach value we find (this gives us a reversed version of the initial list)
    2. traverse and compare the first `length/2` elements of both lists, returning false if they don't match, true otherwise
 */
func isPalindrome(_ list: Node<Character>) -> Bool {
    var reversed: Node<Character>?
    var runner: Node<Character>? = list
    var length: Int = 0

    // build reversed list and increment length
    while runner != nil {
        let newNode = Node<Character>(value: runner!.value)
        newNode.next = reversed
        reversed = newNode
        length += 1
        runner = runner!.next
    }

    // compare first length/2 elements of the two lists
    runner = list
    for _ in 0..<length / 2 {
        guard runner!.value == reversed!.value else { return false }
        runner = runner!.next
        reversed = reversed!.next
    }

    return true
}

let palindromeTest1 = makeListFrom("aba")
print("(\(palindromeTest1.description)) is a palindrome: \(isPalindrome(palindromeTest1))")
let palindromeTest2 = makeListFrom("abba")
print("(\(palindromeTest2.description())) is a palindrome: \(isPalindrome(palindromeTest2))")
let palindromeTest3 = makeListFrom("abca")
print("(\(palindromeTest3.description())) is a palindrome: \(isPalindrome(palindromeTest3))")
let palindromeTest4 = makeListFrom("redrumsirismurder")
print("(\(palindromeTest4.description())) is a palindrome: \(isPalindrome(palindromeTest4))")

/*: ---
 ## 2.7 Intersection: Given two singly-linked lists, determine if the two lists intersect. Return the intersecting node.
 
 - Note: Intersection is defined as the same node (by reference), not just a node containing the same value
 
 * Callout(Plan): Traverse the first list adding each node (or its address) to a Set. Traverse the second list, checking each node (or its address) for existence in the set.
 
 * Callout(Questions):
    1. Are `Node`s `Hashable`? Not to my knowledge.
 2. Can we get the address of a `Node`? Maybe. (Yes, see [General Helpers](../../Sources/General%20Helpers.swift).)
 */
func intersection<T: Hashable>(between list1: Node<T>, and list2: Node<T>) -> Node<T>? {
    var nodes = Set<Int>()
    var runner = list1

    while runner.next != nil {
        nodes.insert(intAddress(of: runner))
        runner = runner.next!
    }

    runner = list2
    while runner.next != nil {
        if nodes.contains(intAddress(of: runner)) {
            return runner
        }

        runner = runner.next!
    }

    return nil
}

let intersectionList = makeListFrom("ABCDEF")
let intersectionListC = intersectionList.next?.next
let intersectionList2 = makeListFrom("QRS")
let intersectionList2End = intersectionList2.next?.next
intersectionList2End?.next = intersectionListC

print("intersectionList: \(intersectionList.description())")
print("intersectionList2: \(intersectionList2.description())")
print("intersection(between: intersectionList, and: intersectionList2): \(intersection(between: intersectionList, and: intersectionList2)!.description())")

/*: ---
 ## 2.8 Loop Detection: given a circular linked list, implement an algorithm that returns the node at the beginning of the loop.
 
 * Callout(Definition): Circular linked list: A (corrupt) linked list in which a node's next pointer points to an earlier node, so as to make a loop in the linked list.
 
 - Example:
    Input:  `A -> B -> C -> D -> E -> C` [the same `C` as earlier]
 
    Output: `C`
 
 * Callout(Plan): Walk the list, storing the address of each node in a `Set`. If the address already exists in the set, we have found our loop node.
 */
func loopExists<T: Hashable>(in list: Node<T>) -> Node<T>? {
    var nodes = Set<Int>()
    var runner = list
    while runner.next != nil {
        let address = intAddress(of: runner)
        guard !nodes.contains(address) else { return runner }
        nodes.insert(address)
        runner = runner.next!
    }

    return nil
}

let nonLoopingList = makeListFrom("ABCDE")
let loopingList = makeListFrom("ABCDE")
let loopingListC = loopingList.next?.next
let loopingListEnd = end(of: loopingList)
loopingListEnd.next = loopingListC

loopExists(in: nonLoopingList)
loopExists(in: loopingList)?.value

//: While my solution *does* work, the book has another solution that relies upon the `FastRunner / SlowRunner` approach. Here it is...

func loopExists2<T: Hashable>(in list: Node<T>) -> Node<T>? {
    var slow: Node<T>? = list
    var fast: Node<T>? = list

    // Find meeting point. This will be `LOOP_SIZE - k` steps into the linked list.
    while fast != nil && fast?.next != nil {
        slow = slow!.next
        fast = fast!.next!.next
        if slow === fast { break }
    }

    // Error check - no meeting point, and therefore no loop
    if fast == nil || fast?.next == nil { return nil }

    // Move `slow` to head. Keep `fast` at collision point. Each are `k` steps from the loop start. If they move at the same pace, they must meet as loop start.
    slow = list
    while slow !== fast {
        slow = slow!.next
        fast = fast!.next
    }

    // Both now point at the start of the loop
    return fast
}

loopExists(in: nonLoopingList)
loopExists(in: loopingList)?.value

//: ---
//: [Previous](@previous)  [Next](@next)
