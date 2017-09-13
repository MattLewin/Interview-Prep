import Foundation

//: # Trees and Graphs

/*: ---
 Helper methods and data structures
 */

public class BinaryTreeNode<Element>: CustomStringConvertible {

    public var data: Element
    public var left: BinaryTreeNode<Element>?
    public var right: BinaryTreeNode<Element>?

    /// An optional function to be executed when "visiting" this node
    public var visit: (() -> Void)?

    init(data: Element) {
        self.data = data
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return "*** DESCRIPTION NOT YET IMPLEMENTED ***"
    }
}

// MARK: Binary Tree Traversal

/// Perform in-order traversal of `node`. (i.e., left branch, current node, right branch)
///
/// - Parameter node: the node to be traversed
public func inOrderTraversal<T>(_ node: BinaryTreeNode<T>?) {
    guard let root = node else { return }
    inOrderTraversal(root.left)
    if let visitor = root.visit {
        visitor()
    }
    inOrderTraversal(root.right)
}

/// Perform pre-order traversal of `node`. (i.e., current node, left branch, right branch)
///
/// - Parameter node: the node to be traversed
public func preOrderTraversal<T>(_ node: BinaryTreeNode<T>?) {
    guard let root = node else { return }
    if let visitor = root.visit {
        visitor()
    }
    preOrderTraversal(root.left)
    preOrderTraversal(root.right)
}

/// Perform post-order traversal of `node`. (i.e., left branch, right branch, current node)
///
/// - Parameter node: the node to be traversed
public func postOrderTraversal<T>(_ node: BinaryTreeNode<T>?) {
    guard let root = node else { return }
    postOrderTraversal(root.left)
    postOrderTraversal(root.right)
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

    public var data: Element
    public var adjacent = [GraphNode<Element>]()

    public var visit: (() -> Void)?
    public var visited = false

    init(data: Element) {
        self.data = data
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return "*** DESCRIPTION NOT YET IMPLEMENTED ***"
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

