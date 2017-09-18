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


//: ---
//: [Previous](@previous)
