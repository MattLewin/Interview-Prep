import Foundation

//: # Trees and Graphs

/*: ---
 Helper methods and data structures
 */

public class BinaryTreeNode<Element>: CustomStringConvertible {

    public var value: Element
    public var left: BinaryTreeNode<Element>?
    public var right: BinaryTreeNode<Element>?

    /// An optional function to be executed when "visiting" this node
    public var visit: (() -> Void)?

    public init(value: Element) {
        self.value = value
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return "*** DESCRIPTION NOT YET IMPLEMENTED ***"
    }
}

// MARK: Binary Tree Traversal

var height = 0

/// Perform in-order traversal of `node`. (i.e., left branch, current node, right branch)
///
/// - Parameters
///   - node: the node to be traversed
///   - debug: whether to print the tree while traversing (defaults to `false`)
public func inOrderTraversal<T>(_ node: BinaryTreeNode<T>?, debug: Bool = false) {
    guard let root = node else { return }
    var indent = ""
    if debug {
        height += 1
        indent = String(repeating: "=", count: height)
    }

    if debug && root.left != nil { print("\(indent) L(h:\(height))") }
    inOrderTraversal(root.left, debug: debug)

    if debug { print("\(indent) N(h:\(height)) val: \(root.value)") }
    if let visitor = root.visit {
        visitor()
    }

    if debug && root.right != nil { print("\(indent) R(h:\(height))") }
    inOrderTraversal(root.right, debug: debug)

    if debug { height -= 1 }
}

/// Perform pre-order traversal of `node`. (i.e., current node, left branch, right branch)
///
/// - Parameters
///   - node: the node to be traversed
///   - debug: whether to print the tree while traversing (defaults to `false`)
public func preOrderTraversal<T>(_ node: BinaryTreeNode<T>?, debug: Bool = false) {
    guard let root = node else { return }
    var indent = ""
    if debug {
        height += 1
        indent = String(repeating: "=", count: height)
    }

    if debug { print("\(indent) N(h:\(height)) val: \(root.value)") }
    if let visitor = root.visit {
        visitor()
    }
    if debug && root.left != nil { print("\(indent) L(h:\(height))") }
    preOrderTraversal(root.left, debug: debug)

    if debug && root.right != nil { print("\(indent) R(h:\(height))") }
    preOrderTraversal(root.right, debug: debug)

    if debug { height -= 1 }
}

/// Perform post-order traversal of `node`. (i.e., left branch, right branch, current node)
///
/// - Parameters
///   - node: the node to be traversed
///   - debug: whether to print the tree while traversing (defaults to `false`)
public func postOrderTraversal<T>(_ node: BinaryTreeNode<T>?, debug: Bool = false) {
    guard let root = node else { return }
    var indent = ""
    if debug {
        height += 1
        indent = String(repeating: "=", count: height)
    }

    if debug && root.left != nil { print("\(indent) L(h:\(height))") }
    postOrderTraversal(root.left, debug: debug)

    if debug && root.right != nil { print("\(indent) R(h:\(height))") }
    postOrderTraversal(root.right, debug: debug)

    if debug { print("\(indent) N(h:\(height)) val: \(root.value)") }
    if let visitor = root.visit {
        visitor()
    }

    if debug { height -= 1 }
}

// MARK: - 

public class Graph<Element>: CustomStringConvertible {

    public var nodes = [GraphNode<Element>]()

    // MARK: CustomStringConvertible

    public var description: String {
        return "*** DESCRIPTION NOT YET IMPLEMENTED ***"
    }
}

public class GraphNode<Element>: CustomStringConvertible {

    public var value: Element
    public var adjacent = [GraphNode<Element>]()

    public var visit: (() -> Void)?
    public var visited = false

    public init(value: Element) {
        self.value = value
    }

    // MARK: CustomStringConvertible

    public var description: String {
        let elementType = String(describing: Element.self)
        return "GraphNode<\(elementType)> { value:\(value), adjacent nodes:\(adjacent.count) }"
    }
}

// MARK: Graph Search / Traversal

public func depthFirstSearch<T>(_ root: GraphNode<T>?) {
    guard let root = root else { return }
    if let visitor = root.visit {
        visitor()
    }
    root.visited = true

    for node in root.adjacent {
        if !node.visited {
            depthFirstSearch(node)
        }
    }
}

public func breadthFirstSearch<T>(_ root: GraphNode<T>?) {
    guard let root = root else { return }
    let toProcess = Queue<GraphNode<T>>()
    root.visited = true
    toProcess.enqueue(root)

    repeat {
        let head = try! toProcess.dequeue()
        if let visitor = head.visit {
            visitor()
        }
        for node in head.adjacent {
            if node.visited == false {
                node.visited = true
                toProcess.enqueue(node)
            }
        }
    } while !toProcess.isEmpty()
}

