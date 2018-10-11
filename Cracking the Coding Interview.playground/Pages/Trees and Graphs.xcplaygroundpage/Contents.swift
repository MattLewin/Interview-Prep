//: [Previous](@previous)
//: # Trees and Graphs
import Foundation
/*: ---
 ## 4.1 Route Between Nodes
 ### Given a directed graph, design an algorithm to find out whether there is a route between two nodes.
 
 * Callout(Thoughts): This sounds like a simple breadth-first search from the `source` to the `target`. That is, traverse each adjacent node from `source` looking for `target`. If `target` isn't found, check each adjacent node of the nodes adjacent to `target`. Repeat until `target` is found or all adjacent nodes checked.

 - Callout(Further Thoughts): Because we are not seeking the shortest path, simply whether there *is* a path, there is no reason we must use a breadth-first search instead of a depth-first search. Thus, I will implement both.
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
 ## 4.2 Minimal Tree
 ### Given a sorted (increasing order) array with unique integer elements, write an algorithm to create a binary search tree with minimal height.
 
 * Callout(Thoughts & Plan):
    1. BST *does not* need to be complete
    2. We know element count, so let's divide it in half, and then process each slice
        1. if element count is odd, middle index is root (the point at which we divide the array)
        2. if element count is even, we can pick an element to be root. *Let's use the first element of the right-side slice.*
        3. if element count is 1, return a node with that value
        4. if element count is 2, return a node with `root = elements[1]` and `root.left = elements[0]`
        5. if element count is 3, return a node with root, left, and right equal to `elements[1]`, `elements[0]`, and `elements[2]`, respectively

 - Note: if element count is 0, behavior is undefined
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
 ## 4.3 List of Depths
 ### Given a binary tree, create an algorithm that creates a linked list of all the nodes at each depth. (i.e., if you have a tree of depth `D`, you will have `D` linked lists.)
 
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
 ## 4.4 Check Balanced
 ### Implement a function to check if a binary tree is balanced. For the purposes of this question, a balanced tree is defined as a tree such that the heights of the two subtrees of any node never differ by more than one.
 
 * Callout(Thoughts):
    1. Given a node, we need to determine the height of each subtree. --> we don't technically need the height, just need to determine whether heights differ by more than 1. Can we use this distinction?
    2. If we do want to determine height of each subtree, how would we do this and "communicate" it to the parent node?
    3. Function to determine height of tree returning that height. Call with left and right subtrees, and compare. Return whichever height is greater, as long as the difference isn't more than 1, otherwise...*what?*
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
    return string.lazy.map { char in
        BinaryTreeNode<Character>(value: char)
    }
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
 ## 4.5 Validate Binary Search Tree
 ### Implement a function to check whether a binary tree is a binary *search* tree.

 * Callout(Thoughts):
     1. Definition of BST: a binary tree where the value of each node in the left subtree is <= the node value, and the value of every node in the right subtree is > the node value.
     2. At root of tree, `max` and `min` are undefined
     3. When we traverse left, we pass along `min`, and we update `max` with the value of the node we are leaving
     4. When we traverse right, we pass along `max`, and we update `min` with the value of the node we are leaving
     5. If `node`'s value is `<= min`, this is *not* a binary search tree
     6. If `node`'s value is `> max`, this is *not* a binary search tree
     7. If we run out of nodes and haven't tripped over (5) or (6), this is a binary search tree
 */
func isBST<T: Comparable>(_ node: BinaryTreeNode<T>, min: T? = nil, max: T? = nil) -> Bool {
    let value = node.value
    if min != nil && value <= min! {
        return false
    }

    if max != nil && value > max! {
        return false
    }

    if node.left != nil && !isBST(node.left!, min: min, max: value) {
        return false
    }

    if node.right != nil && !isBST(node.right!, min: value, max: max) {
        return false
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
        / \     \
       /   \     \
      B     D'    F
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
valid2_4_5[4].right = valid2_4_5[5] // E -> F

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

/*:
 **IN**valid binary tree #3
 ````
        D
       / \
      B   E
     /
    A
     \
      C
 ````
 */
let invalid3_4_5 = createNodes(from: "ABCDE")
let invalid3_4_5_root = invalid3_4_5[3] // D
invalid3_4_5[3].left = invalid3_4_5[1]  // D -> B
invalid3_4_5[3].right = invalid3_4_5[4] // D -> E
invalid3_4_5[1].left = invalid3_4_5[0]  // B -> A
invalid3_4_5[0].right = invalid3_4_5[2] // A -> C

result_4_5 = isBST(invalid3_4_5_root)
print("isBST(invalid3_4_5_root): \(result_4_5) [" + ((result_4_5==false) ? "correct" : "incorrect") + "]")

/*: ---
 ## 4.6 Successor
 ### Write an algorithm to find the "next" node (i.e., in-order successor) of a given node in a binary search tree. You may assume that each node has a link to its parent.

 * Callout(Thoughts):
     1. in-order is left child, node, right child
     2. if node has right child, leftmost leaf of that child is successor, else
     3. if node has no parent, it has no successor, else
     4. if node is left child of parent, parent is successor, else
     5. node is right child of parent => successor is parent of the first ancestor that is a left child (i.e., climb tree until current node == currentNode.parent.left), else
     6. no successor exists
*/
func successor<T: Comparable>(to node: BinaryTreeNode<T>) -> BinaryTreeNode<T>? {
    if node.right != nil {
        return minNode(node.right!)
    }

    guard let parent = node.parent else { return nil } // no right child, no parent == root node w/o successor

    if parent.left != nil && parent.left! === node {
        return parent
    }

    var currentNode: BinaryTreeNode<T>? = parent
    while currentNode != nil {
        guard let cnParent = currentNode?.parent else {
            // reached root of BST w/o finding a left child node
            return nil
        }
        guard let parentLeft = cnParent.left else {
            currentNode = cnParent
            continue
        }
        if parentLeft.value == currentNode!.value {
            // Notice we are comparing value, not objects above. This allows for a <= relationship between parent and left child
            return cnParent
        }

        currentNode = cnParent
    }

    return nil
}

func minNode<T>(_ root: BinaryTreeNode<T>) -> BinaryTreeNode<T> {
    var currentNode = root
    while currentNode.left != nil {
        currentNode = currentNode.left!
    }
    return currentNode
}

print("\n---------- 4.6 Successor ----------")
var result_4_6: BinaryTreeNode<Character>?

/*:
 binary search tree #1
 ```
        C
       / \
      /   \
     B     E
    /     / \
   /     /   \
  A     D     F
 ```
 */
let bst1_4_6_pict = """
binary search tree #1
        C
       / \\
      /   \\
     B     E
    /     / \\
   /     /   \\
  A     D     F

"""
let bst1_4_6 = createNodes(from: "ABCDEF")
bst1_4_6[2].left = bst1_4_6[1]   // C -> B
bst1_4_6[2].right = bst1_4_6[4]  // C -> E
bst1_4_6[1].left = bst1_4_6[0]   // B -> A
bst1_4_6[4].left = bst1_4_6[3]   // E -> D
bst1_4_6[4].right = bst1_4_6[5]  // E -> F

bst1_4_6[1].parent = bst1_4_6[2] // C <- B
bst1_4_6[4].parent = bst1_4_6[2] // C <- E
bst1_4_6[0].parent = bst1_4_6[1] // B <- A
bst1_4_6[3].parent = bst1_4_6[4] // E <- D
bst1_4_6[5].parent = bst1_4_6[4] // E <- F

let bst1_4_6_root = bst1_4_6[2]

print(bst1_4_6_pict)
result_4_6 = successor(to: bst1_4_6[0]) // test A
print("successor(to: A): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="B") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: bst1_4_6[2]) // test C
print("successor(to: C): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="D") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: bst1_4_6[5]) // test F
print("successor(to: F): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value==nil) ? "correct" : "incorrect") + "]")

/*:
 binary search tree #2
 ```
                G
               / \
              /   \
             /     \
            E       K
           / \     / \
          /   \   /   \
         /    |   |    \
        B     F   I     M
       / \       / \   / \
      /   \     /   |  |  \
     A     C   H    J  L   N
            \
             D
 */
let bst2_4_6_pict = """
      binary search tree #2
                G
               / \\
              /   \\
             /     \\
            E       K
           / \\     / \\
          /   \\   /   \\
         /    |   |    \\
        B     F   I     M
       / \\       / \\   / \\
      /   \\     /   |  |  \\
     A     C   H    J  L   N
            \\
             D

"""
let A = BinaryTreeNode<Character>(value: "A")
let B = BinaryTreeNode<Character>(value: "B")
let C = BinaryTreeNode<Character>(value: "C")
let D = BinaryTreeNode<Character>(value: "D")
let E = BinaryTreeNode<Character>(value: "E")
let F = BinaryTreeNode<Character>(value: "F")
let G = BinaryTreeNode<Character>(value: "G")
let H = BinaryTreeNode<Character>(value: "H")
let I = BinaryTreeNode<Character>(value: "I")
let J = BinaryTreeNode<Character>(value: "J")
let K = BinaryTreeNode<Character>(value: "K")
let L = BinaryTreeNode<Character>(value: "L")
let M = BinaryTreeNode<Character>(value: "M")
let N = BinaryTreeNode<Character>(value: "N")

A.parent = B
B.parent = E; B.left = A; B.right = C
C.parent = B; C.right = D
D.parent = C
E.parent = G; E.left = B; E.right = F
F.parent = E
G.left = E; G.right = K
H.parent = I
I.parent = K; I.left = H; I.right = J
J.parent = I;
K.parent = G; K.left = I; K.right = M
L.parent = M;
M.parent = K; M.left = L; M.right = N
N.parent = M;

let bst2_4_6_root = G

print("")
print(bst2_4_6_pict)
result_4_6 = successor(to: A)
print("successor(to: A): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="B") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: C)
print("successor(to: C): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="D") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: D)
print("successor(to: D): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="E") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: G)
print("successor(to: G): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="H") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: J)
print("successor(to: J): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value=="K") ? "correct" : "incorrect") + "]")

result_4_6 = successor(to: N)
print("successor(to: N): \(result_4_6?.value ?? "∅") [" + ((result_4_6?.value==nil) ? "correct" : "incorrect") + "]")

/*: ---
 ## 4.7 Build Order
 ### You are given a list of projects and a list of dependencies, which is a list of pairs of projects, where the second project depends on the first project. All of a project's dependencies must be built before the project is built. Find a build order that will allow the projects to be built, or return an error if there is no valid build order.

 ````
 Input:
     projects: a, b, c, d, e, f
     dependencies: (a,d), (f,b), (b,d), (f,a), (d,c)

 Output: f, e, a, b, d, c
 ````

 * Callout(Thoughts):
     1. projects are each a vertex, and dependencies are each a directed edge
     2. we have to determine whether there is a path from any one vertex to all the others

 - Callout(More Considered Thoughts):
     1. build the graph of each vertex with the edges from the project to the dependency, counting the number of "depending" projects
     2. traverse all projects with 0 "depending" projects (i.e., no incoming edges), marking each vertex as visited and pushing it on a stack
     3. confirm all vertexes/projects visited. If so, the stack is the build order
 */
struct ProjectGraph: CustomStringConvertible {
    class Project: CustomStringConvertible {
        let value: Character
        var visited = false
        var dependencies = [Project]()
        var dependingProjects = 0

        init(value: Character) {
            self.value = value
        }

        var description: String {
            return "[value: \(value), dependingProjects: \(dependingProjects), dependencies:\(dependencies.count)]"
        }
    }

    var projects = [Project]()

    func buildOrder() -> [Character]? {
        var orderStack = [Character]()
        var toVisit = [Project]()

        toVisit.append(contentsOf: projects.filter({ $0.dependingProjects == 0 }))

        while !toVisit.isEmpty {
            let project = toVisit.removeFirst()
            guard !project.visited else { continue }
            orderStack.append(project.value)
            toVisit.append(contentsOf: project.dependencies)
            project.visited = true
        }

        // If any of the projects have not been visited, there is no valid build order
        guard projects.filter({ $0.visited == false }).isEmpty else { return nil }

        return orderStack.reversed()
    }

    var description: String {
        return String(describing: projects)
    }
}

func buildProjectGraph(_ num: Int) -> ProjectGraph? {
    switch num {
    case 1:
        let projects = [
            ProjectGraph.Project(value: "A"),
            ProjectGraph.Project(value: "B"),
            ProjectGraph.Project(value: "C"),
            ProjectGraph.Project(value: "D"),
            ProjectGraph.Project(value: "E"),
            ProjectGraph.Project(value: "F"),
            ]
        projects[3].dependencies.append(projects[0]) // D depends on A
        projects[0].dependingProjects += 1
        projects[1].dependencies.append(projects[5]) // B depends on F
        projects[5].dependingProjects += 1
        projects[3].dependencies.append(projects[1]) // D depends on B
        projects[1].dependingProjects += 1
        projects[0].dependencies.append(projects[5]) // A depends on F
        projects[5].dependingProjects += 1
        projects[2].dependencies.append(projects[3]) // C depends on D
        projects[3].dependingProjects += 1

        var graph = ProjectGraph()
        graph.projects = projects
        return graph

    default:
        return nil

    }
}

print("\n---------- 4.7 Build Order ----------")

let projectGraph = buildProjectGraph(1)!
print(projectGraph.buildOrder()!)

/*: ---
 ## 4.8 First Common Ancestor
 ### Design an algorithm and write code to find the first common ancestor of two nodes in a binary tree. Avoid storing additional nodes in a data structure. NOTE: this is not necessarily a BST.

 * Callout(Thoughts):
     - Do we have parent references in nodes?
     - Can we determine a path from `root` to first node, `X`, and then unwind some recursion to seek a path to second node, `Y`?
     - Obviously, one node must be to the right of the other. Can we use this somehow?

 - Callout(Implementation #1):
     1. Assuming we have parent references
     2. Go to `X.parent`
     3. If `parent.left == X`, search for `Y` in `parent.right`. Do the reverse if `parent.right == X`
     4. If `parent` has only one child, we are now seeking the common ancestor of `parent` and `parent.parent`
     5. If we find `Y`, `parent` is first common ancestor
     6. If we don't find `Y`, we are now seeking the common ancestor of `parent` and `parent.parent`
     7. If we reach a node without parents, we have screwed up

 * Callout(Implementation #2):
     1. Assume we *do not* have parent references
     2. Recursively find path from root to first node, `X`
     3. Upon finding `X`, unwrap the recursion, and we are in `X.parent`
     4. Search for second node, `Y`, from there
     5. If we find `Y`, "first common ancestor" is the node we are in
     6. Note: the challenge here is to communicate back through all the recursion that we have found the "fca" an what it is
 */
func fcaWithParents<T>(of x: BinaryTreeNode<T>, and y: BinaryTreeNode<T>) -> BinaryTreeNode<T> {
    var newX = x
    var parent = x.parent!
    var searchNode: BinaryTreeNode<T>

    repeat {
        guard parent.left != nil, parent.right != nil else {
            newX = parent
            parent = parent.parent!
            continue
        }

        if parent.left! === newX {
            searchNode = parent.right!
        }
        else {
            searchNode = parent.left!
        }

        guard searchNode !== y else { return parent }
        guard !find(y, under: searchNode) else { return parent }
        newX = parent
        parent = parent.parent!
    } while true

    assert(1 == 0)
}

func fcaWOParents<T>(in under: BinaryTreeNode<T>, from x: BinaryTreeNode<T>, to y: BinaryTreeNode<T>) -> BinaryTreeNode<T>? {
    if under === x { return x }
    var ancestorOrX: BinaryTreeNode<T>?

    if under.left != nil {
        ancestorOrX = fcaWOParents(in: under.left!, from: x, to: y)
    }
    if ancestorOrX == nil && under.right != nil {
        ancestorOrX = fcaWOParents(in: under.right!, from: x, to: y)
    }

    // walked this entire subtree and did not find X (or any of its ancestors, obviously)
    guard ancestorOrX != nil else { return nil }

    // found X's parent or older relation. Now we need to find Y.
/*:
 * Callout(Explanation of following code):
     We need a means to "communicate" to the enclosing recursive calls that we have found `X`, `Y` and the "first
     common ancestor." We do this by passing back `X` itself, and then searching `under` until we find a common
     ancestor. Once we have found that ancestor, we pass `under` back to become `ancestorOrX` and do no more work.
 */
    guard ancestorOrX === x else { return ancestorOrX }
    guard find(y, under: under) else { return ancestorOrX }
    return under
}

func find<T>(_ node: BinaryTreeNode<T>, under: BinaryTreeNode<T>) -> Bool {
    // depth first search
    if under === node { return true }
    if under.left != nil && find(node, under: under.left!) {
        return true
    }
    if under.right != nil && find(node, under: under.right!) {
        return true
    }

    return false
}

print("\n---------- 4.8 First Common Ancestor ----------")
var result_4_8: BinaryTreeNode<Character>
/*:
 We will use "binary search tree #2" from `4.6` to test
 ```
                G
               / \
              /   \
             /     \
            E       K
           / \     / \
          /   \   /   \
         /    |   |    \
        B     F   I     M
       / \       / \   / \
      /   \     /   |  |  \
     A     C   H    J  L   N
            \
             D
 */
print("")
print(bst2_4_6_pict)

result_4_8 = fcaWithParents(of: E, and: K)
print("fcaWithParents(of: E, and: K): \(result_4_8) [" + ((result_4_8.value=="G") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWithParents(of: A, and: F)
print("fcaWithParents(of: A, and: F): \(result_4_8) [" + ((result_4_8.value=="E") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWithParents(of: J, and: N)
print("fcaWithParents(of: J, and: N): \(result_4_8) [" + ((result_4_8.value=="K") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWithParents(of: H, and: C)
print("fcaWithParents(of: H, and: C): \(result_4_8) [" + ((result_4_8.value=="G") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWithParents(of: I, and: M)
print("fcaWithParents(of: I, and: M): \(result_4_8) [" + ((result_4_8.value=="K") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWOParents(in: bst2_4_6_root, from: E, to: K)!
print("fcaWOParents(in: bst2_4_6_root, from: E, to: K): \(result_4_8) [" + ((result_4_8.value=="G") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWOParents(in: bst2_4_6_root, from: A, to: F)!
print("fcaWOParents(in: bst2_4_6_root, from: A, to: F): \(result_4_8) [" + ((result_4_8.value=="E") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWOParents(in: bst2_4_6_root, from: J, to: N)!
print("fcaWOParents(in: bst2_4_6_root, from: J, to: N): \(result_4_8) [" + ((result_4_8.value=="K") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWOParents(in: bst2_4_6_root, from: H, to: C)!
print("fcaWOParents(in: bst2_4_6_root, from: H, to: C): \(result_4_8) [" + ((result_4_8.value=="G") ? "correct" : "incorrect") + "]")

result_4_8 = fcaWOParents(in: bst2_4_6_root, from: I, to: M)!
print("fcaWOParents(in: bst2_4_6_root, from: I, to: M): \(result_4_8) [" + ((result_4_8.value=="K") ? "correct" : "incorrect") + "]")

/*: ---
 ## 4.9 BST Sequences
 ### A binary search tree was created by traversing through an array from left to right, inserting each element. Given a binary search tree with distinct elements, print all possible arrays that could have produced this tree.

 * Callout(Thoughts/Plan):
     1. The `root.value` is always the first value of each of the result arrays
     2. When visiting a node, we add each child node to a list of "reachables" (sort of like a queue in a breadth-first search)
     3. We append `node.value` to the "partial result"
     4. For every node in "reachables," we remove it from "reachables" and then recursively process that node with the remaining "reachables." (i.e., we return to step #2, above)
     5. If the reachables list is empty, we have found a sequence and return it
     6. The result of the "processing" in #4 is one sequence for each "reachable" node. The array of these sequences is the desired result, namely all possible arrays that could have produced the provided BST
 */
func process<T>(node: BinaryTreeNode<T>, reachables: [BinaryTreeNode<T>]? = nil, partialResult: [T]? = nil) -> [[T]] {
    var newReachables = reachables ?? [BinaryTreeNode<T>]()
    var newPartial = partialResult ?? [T]()
    newPartial.append(node.value)

    if node.left != nil {
        newReachables.append(node.left!)
    }
    if node.right != nil {
        newReachables.append(node.right!)
    }
    guard !newReachables.isEmpty else {
        return [newPartial]
    }

/*:
The procedural code below implements step #4 of the "Thoughts/Plan" above. It has been replaced by the more "Swifty,"
functional code below it.

    var results = [[T]]()
    for reachableNode in newReachables {
        let result = process(node: reachableNode,
                             reachables: newReachables.filter({ $0 !== reachableNode}),
                             partialResult: newPartial)
        results.append(contentsOf: result)
    }
    return results
 */
    let sequences = newReachables.map { reachableNode in
        process(node: reachableNode,
                reachables: newReachables.filter({ $0 !== reachableNode}),
                partialResult: newPartial)
    }

    return sequences.flatMap({ $0 })
}

print("\n---------- 4.9 BST Sequences ----------")
/*:
 we will use "valid binary tree #1" from `4.5` for our first test
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
let bst1_4_5_pict = """
 valid binary tree #1
        C
       / \\
      /   \\
     B     D
    /       \\
   /         \\
  A           E

"""
print(bst1_4_5_pict)
print("Arrays that could have created the above binary search tree: (trust me, it's correct)")
print(process(node: valid1_4_5_root))

/*:
 We will use "binary search tree #1" from `4.6` for our second test
 ```
        C
       / \
      /   \
     B     E
    /     / \
   /     /   \
  A     D     F
 ```
 */
print("")
print(bst1_4_6_pict)

print("Arrays that could have created the above binary search tree: (trust me, it's correct)")
print(process(node: bst1_4_6_root))

/*: ---
 ## 4.10 Check Subtrees
 ### `T1` & `T2` are two very large subtrees, with `T1` much larger than `T2`. Create an algorithm to determine if `T2` is a subtree of `T1`. A tree, `T2`, is a subtree of `T1`, if there exists a node, `n`, in `T1` such that the subtree of `n` is identical (in values) to `T2`. That is, if you cut off the tree at node `n`, the two trees would be identical.

 * Callout(Thoughts):
     1. Need to find two nodes with the same value, and then check if their subtrees are identical
     2. BFS through `T1` searching for a node where `T1`'s value equals `T2`'s root's value
     3. When we find a node, compare the two subtrees to see if they are the same

 - Callout(Book's "simple" solution):
     1. Need to find two nodes with the same value, and then check if they are identical
     2. Create a "flattened" representation of `T1` and `T2`
     3. Check whether "flattened" `T1` contains "flattened" `T2`
     4. If the flattened representations are `String`s, we can do this with `String.contains()` (Is that cheating?)
     5. Since these trees are very large, is creating the "flattened" representation time and memory inefficient?
 */
func checkSubtrees<T: Comparable>(T1: BinaryTreeNode<T>?, T2: BinaryTreeNode<T>?) -> Bool {
    guard T1 != nil else { // if T1 is empty, it can't contain a subtree
        return false
    }

    guard T2 != nil else { // an empty T2 is always a subtree of T1 ;)
        return true
    }

    guard T1 != T2 else {
        return true
    }

    return checkSubtrees(T1: T1?.left, T2: T2) || checkSubtrees(T1: T1?.right, T2: T2)
}

func ==<T: Comparable>(lhs: BinaryTreeNode<T>?, rhs: BinaryTreeNode<T>?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil): // Empty trees are obviously equal in value
        return true

    case (_, nil): fallthrough
    case (nil, _):
        // if one is empty and the other is not, they can't be equal
        return false

    case let (l, r) where l?.value != r?.value:
        return false

    default:
        return lhs?.left == rhs?.left && lhs?.right == rhs?.right
    }
}

func !=<T: Comparable>(lhs: BinaryTreeNode<T>?, rhs: BinaryTreeNode<T>?) -> Bool {
    return !(lhs == rhs)
}

func checkSubtrees2(T1: BinaryTreeNode<Character>, T2: BinaryTreeNode<Character>) -> Bool {
    let flatT1 = flatten(T1)
    let flatT2 = flatten(T2)

    return flatT1.contains(flatT2)
}

func flatten(_ node: BinaryTreeNode<Character>?) -> String {
    guard let n = node  else {
        return String(Character(Unicode.Scalar(0)))
    }

    return String(n.value) + flatten(n.left) + flatten(n.right)
}

print("\n---------- 4.10 Check Subtrees ----------")
var result: Bool
let t = makeBinaryTree(from: "abcdefg")!
result = checkSubtrees(T1: t, T2: t.left!)
print("for binary tree, t, made from \"abcdefg\", checkSubtrees(T1: t, T2: t.left!) is \(result)")
result = checkSubtrees2(T1: t, T2: t.left!)
print("for binary tree, t, made from \"abcdefg\", checkSubtrees2(T1: t, T2: t.left!) is \(result)")

result = checkSubtrees(T1: doiBTree, T2: doiBTree.left!.right!.left!)
print("for binary tree, doiBtree, made from the text of the Declaration of Independence, checkSubtrees(T1: doiBTree, T2: doiBTree.left!.right!.left!) is \(result)")
result = checkSubtrees2(T1: doiBTree, T2: doiBTree.left!.right!.left!)
print("for binary tree, doiBtree, made from the text of the Declaration of Independence, checkSubtrees2(T1: doiBTree, T2: doiBTree.left!.right!.left!) is \(result)")


let u = makeBinaryTree(from: "qyzf")!
result = checkSubtrees(T1: t, T2: u)
print("for binary tree, t, made from \"abcdefg\" and binary tree, u, made from \"qyzf\", checkSubtrees(T1: t, T2: u) is \(result)")
result = checkSubtrees2(T1: t, T2: u)
print("for binary tree, t, made from \"abcdefg\" and binary tree, u, made from \"qyzf\", checkSubtrees2(T1: t, T2: u) is \(result)")

//: The code below is commented out because it takes a ton of time to execute. It's interesting to play with, though
/*:
 ```
var start: Date
var end: Date
var delta: TimeInterval
start = Date()
print("beginning 'checkSubtrees' on Dracula at \(start)")
result = checkSubtrees(T1: dracBTree, T2: dracBTree.left!.right!.left!.left!.right!.right!)
end = Date()
delta = end.timeIntervalSince(start)
print("for binary tree, dracBtree, made from the text of the Dracula, checkSubtrees(T1: dracBTree, T2: dracBTree.left!.right!.left!.left!.right!.right!) is \(result) and took \(delta) seconds to determine that")

start = Date()
print("beginning 'checkSubtrees2' on Dracula at \(start)")
result = checkSubtrees2(T1: dracBTree, T2: dracBTree.left!.right!.left!.left!.right!.right!)
end = Date()
delta = end.timeIntervalSince(start)
print("for binary tree, dracBtree, made from the text of the Dracula, checkSubtrees2(T1: dracBTree, T2: dracBTree.left!.right!.left!.left!.right!.right!) is \(result) and took \(delta) seconds to determine that")
```
 */

//: ---
//: [Previous](@previous)
