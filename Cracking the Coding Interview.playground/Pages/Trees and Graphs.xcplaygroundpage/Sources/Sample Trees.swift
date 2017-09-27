// This file contains pre-made binary trees.
// The smaller of the two trees, "doiBTree," contains the text of the Declaration of Independence. It's about 8,000 characters.
// The larger of the two trees, "dracBTree," contains the text of Bram Stoker's "Dracula." It's about 800,000 characters.

import Foundation

let doiURL = Bundle.main.url(forResource: "Declaration of Independence", withExtension: "txt")
let doiContent = try! String(contentsOf: doiURL!, encoding: String.Encoding.utf8)
public let doiBTree = makeBinaryTree(from: doiContent)!

let dracURL = Bundle.main.url(forResource: "Dracula", withExtension: "txt")
let dracContent = try! String(contentsOf: dracURL!, encoding: String.Encoding.utf8)
public let dracBTree = makeBinaryTree(from: dracContent)!
