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
        return String(describing: value)
    }
}

// MARK: Binary Tree Traversal

/// Perform in-order traversal of `node`. (i.e., left branch, current node, right branch)
///
/// - Parameters
///   - node: the node to be traversed
///   - debug: whether to print the tree while traversing (defaults to `false`)
///   - indent: the indentation string used in debug output
public func inOrderTraversal<T>(_ node: BinaryTreeNode<T>?, debug: Bool = false, indent: String = "") {
    guard let root = node else { return }

    inOrderTraversal(root.left, debug: debug, indent: indent + "L")

    if debug { print("\(indent) \(root.value)") }
    if let visitor = root.visit {
        visitor()
    }

    inOrderTraversal(root.right, debug: debug, indent: indent + "R")
}

/// Perform pre-order traversal of `node`. (i.e., current node, left branch, right branch)
///
/// - Parameters
///   - node: the node to be traversed
///   - debug: whether to print the tree while traversing (defaults to `false`)
///   - indent: the indentation string used in debug output
public func preOrderTraversal<T>(_ node: BinaryTreeNode<T>?, debug: Bool = false, indent: String = "") {
    guard let root = node else { return }

    if debug { print("\(indent) \(root.value)") }
    if let visitor = root.visit {
        visitor()
    }
    preOrderTraversal(root.left, debug: debug, indent: indent + "L")
    preOrderTraversal(root.right, debug: debug, indent: indent + "R")
}

/// Perform post-order traversal of `node`. (i.e., left branch, right branch, current node)
///
/// - Parameters
///   - node: the node to be traversed
///   - debug: whether to print the tree while traversing (defaults to `false`)
///   - indent: the indentation string used in debug output
public func postOrderTraversal<T>(_ node: BinaryTreeNode<T>?, debug: Bool = false, indent: String = "") {
    guard let root = node else { return }
    postOrderTraversal(root.left, debug: debug, indent: indent + "L")
    postOrderTraversal(root.right, debug: debug, indent: indent + "$")

    if debug { print("\(indent) \(root.value)") }
    if let visitor = root.visit {
        visitor()
    }
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

