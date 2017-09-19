//: [Previous](@previous)
//: # Trees and Graphs
import Foundation

/*: ---
 ## 4.1 Route Between Nodes: Given a directed graph, design an algorithm to find out whether there is a route between two nodes.
 
 * Callout(Thoughts): This sounds like a simple breadth-first search from the `source` to the `target`. That is, traverse each adjacent node from `source` looking for `target`. If `target` isn't found, check each adjacent node of the nodes adjacent to `target`. Repeat until `target` is found or all adjacent nodes checked.
 
 
 * Callout(Further Thoughts): Because we are not seeking the shortest path, simply whether there *is* a path, there is no reason we must use a breadth-first search instead of a depth-first search. Thus, I will implement both.
 */
func bfsPathExists<T: Comparable>(from: GraphNode<T>, to: GraphNode<T>) -> Bool {
    var toVisit = [GraphNode<T>]()
    toVisit.append(from)

    repeat {
        let aNode = toVisit.remove(at: 0)
        guard aNode !== to else { return true }
        guard !aNode.visited else { continue }
        aNode.visited = true

        for node in aNode.adjacent {
            guard !node.visited else { continue }
            toVisit.append(node)
        }
    } while toVisit.count > 0

    return false
}

func dfsPathExists<T: Comparable>(from: GraphNode<T>, to: GraphNode<T>) -> Bool {
    guard from !== to else { return true }
    from.visited = true

    for node in from.adjacent {
        guard !node.visited else { continue }
        guard dfsPathExists(from: node, to: to) else {
            continue
        }
        return true
    }
    return false
}

/*:
 To test `bfsPathExists(from:to:)` and `dfsPathExists(from:to:)`, we will use this simple graph

 ![Simple Graph](Simple%20Graph.png)
 */
print("---------- 4.1 Route Between Nodes ----------")
func createGraph() -> [GraphNode<Int>] {
    let nodes = [
        GraphNode<Int>(value: 0),
        GraphNode<Int>(value: 1),
        GraphNode<Int>(value: 2),
        GraphNode<Int>(value: 3),
        GraphNode<Int>(value: 4),
        GraphNode<Int>(value: 5)
    ]

    nodes[0].adjacent = [nodes[1], nodes[4], nodes[5]]
    nodes[1].adjacent = [nodes[3], nodes[4]]
    nodes[2].adjacent = [nodes[1]]
    nodes[3].adjacent = [nodes[2], nodes[4]]
    nodes[4].adjacent = []
    nodes[5].adjacent = []

    return nodes
}

var graph = createGraph()
print("bfsPathExists(from: graph[0], to: graph[3]): \(bfsPathExists(from: graph[0], to: graph[3]))")
graph = createGraph()
print("dfsPathExists(from: graph[0], to: graph[3]): \(dfsPathExists(from: graph[0], to: graph[3]))")

graph = createGraph()
print("bfsPathExists(from: graph[0], to: graph[2]): \(bfsPathExists(from: graph[0], to: graph[2]))")
graph = createGraph()
print("dfsPathExists(from: graph[0], to: graph[2]): \(dfsPathExists(from: graph[0], to: graph[2]))")

graph = createGraph()
print("bfsPathExists(from: graph[1], to: graph[5]): \(bfsPathExists(from: graph[1], to: graph[5]))")
graph = createGraph()
print("dfsPathExists(from: graph[1], to: graph[5]): \(dfsPathExists(from: graph[1], to: graph[5]))")

graph = createGraph()
print("bfsPathExists(from: graph[2], to: graph[4]): \(bfsPathExists(from: graph[2], to: graph[4]))")
graph = createGraph()
print("dfsPathExists(from: graph[2], to: graph[4]): \(dfsPathExists(from: graph[2], to: graph[4]))")

/*: ---
 ## 4.2 Minimal Tree: Given a sorted (increasing order) array with unique integer elements, write an algorithm to create a binary search tree with minimal height.
 
 * Callout(Thoughts & Plan):
    1. BST *does not* need to be complete
    2. We know element count, so let's divide it in half, and then process each slice
        1. if element count is odd, middle index is root (the point at which we divide the array)
        2. if element count is even, we can pick an element to be root. *Let's use the first element of the right-side slice.*
        3. if element count is 1, return a node with that value
        4. if element count is 2, return a node with `root = elements[1]` and `root.left = elements[0]`
        5. if element count is 3, return a node with root, left, and right equal to `elements[1]`, `elements[0]`, and `elements[2]`, respectively

 
 * Note: if element count is 0, behavior is undefined
 */
func makeBST(from elements: [Int]) -> BinaryTreeNode<Int> {
    // Note, this function assumes at least one element in `elements`
    switch elements.count {
    case 1:
        return BinaryTreeNode<Int>(value: elements[0])

    case 2:
        let node = BinaryTreeNode<Int>(value: elements[1])
        node.left = BinaryTreeNode<Int>(value: elements[0])
        return node

    case 3:
        let node = BinaryTreeNode<Int>(value: elements[1])
        node.left = BinaryTreeNode<Int>(value: elements[0])
        node.right = BinaryTreeNode<Int>(value: elements[2])
        return node

    default:
        let rootIndex = elements.count / 2
        let node = BinaryTreeNode<Int>(value: elements[rootIndex])
        node.left = makeBST(from: Array(elements[0..<rootIndex]))
        node.right = makeBST(from: Array(elements[(rootIndex + 1)..<elements.count]))
        return node
    }
}

print("\n---------- 4.2 Minimal Tree ----------")

var elements = [1, 2, 3, 4]
let bst = makeBST(from: elements)
print("Binary Search Tree from \(elements)")
inOrderTraversal(bst, debug: true)

elements = []
for i in 1...5 {
    elements.append(i)
}

print("\nBinary Search Tree from \(elements)")
inOrderTraversal(makeBST(from: elements), debug: true)

elements = []
for i in 1...16 {
    elements.append(i)
}

print("\nBinary Search Tree from \(elements)")
inOrderTraversal(makeBST(from: elements), debug: true)

/*: ---
 ## 4.3 List of Depths: given a binary tree, create an algorithm that creates a linked list of all the nodes at each depth. (i.e., if you have a tree of depth `D`, you will have `D` linked lists.)
 
 * Callout(Thoughts):
    1. preorder traversal (though I think it doesn't matter), adding each node to the appropriate linked list
    2. assume we can use an array to store the set of linked lists
    3. method to traverse takes depth param
 
    - If we cannot use an array, we can omit the depth and include a list to append the nodes to. We would pass in a pointer to *this* level's list. If the next level's list does not exist, create it and append it to the list we were passed prior to processing the child nodes.
 */
class LLNode<Element>: CustomStringConvertible {
    var value: Element
    var next: LLNode<Element>?

    init(value: Element) {
        self.value = value
    }

    var description: String {
        guard next != nil else { return "\(value)" }
        return "\(value), " + next!.description
    }
}

func arrayListOfDepths<T>(array: inout [LLNode<BinaryTreeNode<T>>?], depth: Int, node: BinaryTreeNode<T>) {
    let newLLNode = LLNode<BinaryTreeNode<T>>(value: node)
    if array.count < depth {
        array.append(newLLNode)
    }
    else {
        newLLNode.next = array[depth-1]
        array[depth - 1] = newLLNode
    }

    if node.left != nil {
        arrayListOfDepths(array: &array, depth: (depth + 1), node: node.left!)
    }

    if node.right != nil {
        arrayListOfDepths(array: &array, depth: (depth + 1), node: node.right!)
    }
}

typealias ListOfLinkedLists<Element> = LLNode<LLNode<Element>?>

func listListOfDepths<T>(list: ListOfLinkedLists<BinaryTreeNode<T>>, node: BinaryTreeNode<T>) {
    let newLLNode = LLNode<BinaryTreeNode<T>>(value: node)
    if list.value == nil {
        list.value = newLLNode
    }
    else {
        newLLNode.next = list.value
        list.value = newLLNode
    }

    guard node.left != nil || node.right != nil else { return }

    if list.next == nil {
        list.next = ListOfLinkedLists<BinaryTreeNode<T>>(value: nil)
    }

    if node.left != nil {
        listListOfDepths(list: list.next!, node: node.left!)
    }

    if node.right != nil {
        listListOfDepths(list: list.next!, node: node.right!)
    }
}

print("\n---------- 4.3 List of Depths ----------")
print("** using arrayListOfDepths **")

var bt: BinaryTreeNode<Int>
var nodesArray: [LLNode<BinaryTreeNode<Int>>?]

elements = [1, 2, 3, 4, 5, 6, 7, 8]
bt = makeBST(from: elements)
print("Binary Tree from \(elements)")
inOrderTraversal(bt, debug: false)
nodesArray = [LLNode<BinaryTreeNode<Int>>?]()
arrayListOfDepths(array: &nodesArray, depth: 1, node: bt)
print("nodesArray: \(nodesArray)")
print("")

elements = [1]
bt = makeBST(from: elements)
print("Binary Tree from \(elements)")
inOrderTraversal(bt)
nodesArray = [LLNode<BinaryTreeNode<Int>>?]()
arrayListOfDepths(array: &nodesArray, depth: 1, node: bt)
print("nodesArray: \(nodesArray)")
print("")

elements = Array<Int>(1...64)
bt = makeBST(from: elements)
print("Binary Tree from \(elements)")
inOrderTraversal(bt)
nodesArray = [LLNode<BinaryTreeNode<Int>>?]()
arrayListOfDepths(array: &nodesArray, depth: 1, node: bt)
print("nodesArray: \(nodesArray)")
print("")

print("** using listListOfDepths **")
var nodesList: ListOfLinkedLists<BinaryTreeNode<Int>>

elements = [1, 2, 3, 4, 5, 6, 7, 8]
bt = makeBST(from: elements)
print("Binary Tree from \(elements)")
inOrderTraversal(bt, debug: false)
nodesList = ListOfLinkedLists<BinaryTreeNode<Int>>(value: nil)
listListOfDepths(list: nodesList, node: bt)
print("nodesList: \(nodesList)")
print("")

elements = [1]
bt = makeBST(from: elements)
print("Binary Tree from \(elements)")
inOrderTraversal(bt)
nodesList = ListOfLinkedLists<BinaryTreeNode<Int>>(value: nil)
listListOfDepths(list: nodesList, node: bt)
print("nodesList: \(nodesList)")
print("")

elements = Array<Int>(1...64)
bt = makeBST(from: elements)
print("Binary Tree from \(elements)")
inOrderTraversal(bt)
nodesList = ListOfLinkedLists<BinaryTreeNode<Int>>(value: nil)
listListOfDepths(list: nodesList, node: bt)
print("nodesList: \(nodesList)")
print("")

/*: ---
 ## 4.4 Check Balanced: Implement a function to check if a binary tree is balanced. For the purposes of this question, a balanced tree is defined as a tree such that the heights of the two subtrees of any node never differ by more than one.
 
 * Callout(Thoughts):
    1. Given a node, we need to determine the height of each subtree. --> we don't technically need the height, just need to determine whether heights differ by more than 1. Can we use this distinction?
    2. If we do want to determine height of each subtree, how would we do this and "communicate" it to the parent node?
    3. Function to determine height of tree returning that height. Call with left and right subtrees, and compare. Return whichever height is greater, as long as the difrerence isn't more than 1, otherwise...*what?*
        1. could return a tuple of (height, `true`/`false`) or even an `enum` with those two types
        2. Could just return height and let the enclosing function deal. **<-- let's do this**
 */
func isBalanced<T>(_ root: BinaryTreeNode<T>) -> Bool {
    let leftH = heightOf(root.left)
    let rightH = heightOf(root.right)

    return (abs(leftH - rightH) > 1) ? false : true
}

func heightOf<T>(_ root: BinaryTreeNode<T>?) -> Int {
    guard let node = root else { return 0 }
    let leftH = heightOf(node.left)
    let rightH = heightOf(node.right)
    let greaterHeight = (leftH > rightH) ? leftH : rightH
    return 1 + greaterHeight
}

func createNodes(from string: String) -> [BinaryTreeNode<Character>] {
    var retval = [BinaryTreeNode<Character>]()
    for char in string.characters {
        retval.append(BinaryTreeNode<Character>(value: char))
    }

    return retval
}

print("\n---------- 4.4 Check Balanced ----------")
var result_4_4: Bool

/*:
 ```
        A
       / \
      /   \
     B     C
      \
       \
        D
 ```
 */
let valid1_4_4 = createNodes(from: "ABCD")
valid1_4_4[0].left = valid1_4_4[1]  // A -> B
valid1_4_4[0].right = valid1_4_4[2] // A -> C
valid1_4_4[1].right = valid1_4_4[3] // B -> D

result_4_4 = isBalanced(valid1_4_4[0])
print("isBalanced(valid1_4_4[0]): \(result_4_4) [" + ((result_4_4==true) ? "correct" : "incorrect") + "]")

/*:
 ```
        A
       / \
      /   \
     B     C
    / \     \
   /   \     \
  D     E     F
         \
          \
           G
 ```
 */

let valid2_4_4 = createNodes(from: "ABCDEFG")
valid2_4_4[0].left = valid2_4_4[1]  // A -> B
valid2_4_4[0].right = valid2_4_4[2] // A -> C
valid2_4_4[1].left = valid2_4_4[3]  // B -> D
valid2_4_4[1].right = valid2_4_4[4] // B -> E
valid2_4_4[2].right = valid2_4_4[5] // C -> F
valid2_4_4[4].right = valid2_4_4[6] // E -> G

result_4_4 = isBalanced(valid2_4_4[0])
print("isBalanced(valid2_4_4[0]): \(result_4_4) [" + ((result_4_4==true) ? "correct" : "incorrect") + "]")

/*:
 ```
        A
       /
      /
     B
    /
   /
  C
 ```
 */

let invalid1_4_4 = createNodes(from: "ABC")
invalid1_4_4[0].left = invalid1_4_4[1]  // A -> B
invalid1_4_4[1].left = invalid1_4_4[2]  // C -> C

result_4_4 = isBalanced(invalid1_4_4[0])
print("isBalanced(invalid1_4_4[0]): \(result_4_4) [" + ((result_4_4==false) ? "correct" : "incorrect") + "]")

/*:
 ```
        A
       / \
      /   \
     B     C
      \     \
       \     \
        D     E
       /
      /
     F
    /
   /
  G
 ```
 */

let invalid2_4_4 = createNodes(from: "ABCDEFG")
invalid2_4_4[0].left = invalid2_4_4[1]  // A -> B
invalid2_4_4[0].right = invalid2_4_4[2] // A -> C
invalid2_4_4[1].right = invalid2_4_4[3] // B -> D
invalid2_4_4[2].right = invalid2_4_4[4] // C -> E
invalid2_4_4[3].left = invalid2_4_4[5]  // D -> F
invalid2_4_4[5].left = invalid2_4_4[6]  // F -> G

result_4_4 = isBalanced(invalid2_4_4[0])
print("isBalanced(invalid2_4_4[0]): \(result_4_4) [" + ((result_4_4==false) ? "correct" : "incorrect") + "]")


/*: ---
 ## 4.5 Validate Binary Search Tree: implement a function to check whether a binary tree is a binary *search* tree.

 * Callout(Thoughts):
 1. Definition of BST: a binary tree where the value of each node in the left subtree is <= the root value, and the value of every node in the right subtree is > the root value.
 2. Find max value in left subtree and ensure it is <= root value
 3. Find min value in right subtree and ensure it is > root value
 4. If (2) or (3) is false, this is not a binary search tree
 */
func isBST<T: Comparable>(_ root: BinaryTreeNode<T>) -> Bool {
    if root.left != nil {
        guard compare(subtree: root.left!, to: root.value, using: { lhs, rhs in return lhs <= rhs }) else {
            return false
        }
    }

    if root.right != nil {
        // Note below that we use '>' since any `T` conforming to `Comparable` implements '>'. (I didn't do it above because I wanted
        // to try using a closure.)
        guard compare(subtree: root.right!, to: root.value, using: >) else {
            return false
        }
    }

    return true
}

func compare<T: Comparable>(subtree root: BinaryTreeNode<T>, to value: T, using: (T, T) -> Bool) -> Bool {
    guard using(root.value, value) == true else { return false }
    if root.left != nil {
        guard compare(subtree: root.left!, to: value, using: using) == true else { return false }
    }

    if root.right != nil {
        guard compare(subtree: root.right!, to: value, using: using) == true else { return false }
    }

    return true
}

print("\n---------- 4.5 Validate Binary Search Tree ----------")
var result_4_5: Bool

/*:
 valid binary tree #1
 ```
        C
       / \
      /   \
     B     D
    /       \
   /         \
  A           E
 ```
 */
let valid1_4_5 = createNodes(from: "ABCDE")
let valid1_4_5_root = valid1_4_5[2] // C
valid1_4_5[2].left = valid1_4_5[1]  // C -> B
valid1_4_5[2].right = valid1_4_5[3] // C -> D
valid1_4_5[1].left = valid1_4_5[0]  // B -> A
valid1_4_5[3].right = valid1_4_5[4] // D -> E

result_4_5 = isBST(valid1_4_5_root)
print("isBST(valid1_4_5_root): \(result_4_5) [" + ((result_4_5==true) ? "correct" : "incorrect") + "]")

/*:
 valid binary tree #2
 ````
            D
           / \
          /   \
         C     E
        / \   /
       /  |   |
      B   D'  F
     /
    /
   A
 ````
 */

let valid2_4_5 = createNodes(from: "ABCDEFD")
let valid2_4_5_root = valid2_4_5[3] // D
valid2_4_5[3].left = valid2_4_5[2]  // D -> C
valid2_4_5[3].right = valid2_4_5[4] // D -> E
valid2_4_5[2].left = valid2_4_5[1]  // C -> B
valid2_4_5[2].right = valid2_4_5[6] // C -> D'
valid2_4_5[1].left = valid2_4_5[0]  // B -> A
valid2_4_5[4].left = valid2_4_5[5]  // E -> F

result_4_5 = isBST(valid2_4_5_root)
print("isBST(valid2_4_5_root): \(result_4_5) [" + ((result_4_5==true) ? "correct" : "incorrect") + "]")

/*:
 **IN**valid binary tree #1
 ```
        D
       / \
      /   \
     B     C
    /
   /
  A
 ```
 */
let invalid1_4_5 = createNodes(from: "ABCD")
let invalid1_4_5_root = invalid1_4_5[3] // D
invalid1_4_5[3].left = invalid1_4_5[1]  // D -> B
invalid1_4_5[3].right = invalid1_4_5[2] // D -> C
invalid1_4_5[1].left = invalid1_4_5[0]  // B -> A

result_4_5 = isBST(invalid1_4_5_root)
print("isBST(invalid1_4_5_root): \(result_4_5) [" + ((result_4_5==false) ? "correct" : "incorrect") + "]")

/*:
 **IN**valid binary tree #2
 ````
            D
           / \
          /   \
         C     E
        / \     \
       /   \     \
      A     B     F
             \
              \
               G
 ````
 */

let invalid2_4_5 = createNodes(from: "ABCDEFG")
let invalid2_4_5_root = invalid2_4_5[3] // D
invalid2_4_5[3].left = invalid2_4_5[2]  // D -> C
invalid2_4_5[3].right = invalid2_4_5[4] // D -> E
invalid2_4_5[2].left = invalid2_4_5[0]  // C -> A
invalid2_4_5[2].right = invalid2_4_5[1] // C -> B
invalid2_4_5[1].right = invalid2_4_5[6] // B -> G
invalid2_4_5[4].right = invalid2_4_5[5] // E -> F

result_4_5 = isBST(invalid2_4_5_root)
print("isBST(invalid2_4_5_root): \(result_4_5) [" + ((result_4_5==false) ? "correct" : "incorrect") + "]")


//: ---
//: [Previous](@previous)
