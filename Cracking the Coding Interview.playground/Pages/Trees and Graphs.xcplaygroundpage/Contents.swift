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

//: ---
//: [Previous](@previous)
