import Foundation

// Define your properties struct
struct Properties: Codable {
    var id: String?
    var className: String?
    var type: String?
    var value: Value?
    var width: Int?
    var height: Int?
    var backgroundColor: String?
    var flexDirection: String?
    
    struct Value: Codable {
        var value: String?
        var hook: [String: String]?
    }
}

// Define your TreeNode struct
struct TreeNode: Codable {
    var id: String?
    var t: String
    var tn: String?
    var p: Properties?
    var c: [TreeNode]?
}


func parseJSONStringToSimpleTree(_ jsonString: String) -> TreeNode? {
    let jsonData = Data(jsonString.utf8)
    let decoder = JSONDecoder()
    
    do {
        let rootNode = try decoder.decode(TreeNode.self, from: jsonData)
        return rootNode
    } catch {
        print("Error parsing JSON: \(error)")
        return nil
    }
}

func traverseTree(_ node: TreeNode?, depth: Int = 0, callback: (TreeNode, Int) -> Void) {
    guard let node = node else { return }

    // Call the callback with the current node and its depth
    callback(node, depth)

    // Process children if they exist
    if let children = node.c, !children.isEmpty {
        for child in children {
            traverseTree(child, depth: depth + 1, callback: callback)
        }
    }
}

func printTree(_ node: TreeNode?, indent: String = "", isTail: Bool = true) {
    guard let node = node else { return }
    
    traverseTree(node) { (node, depth) in
        let tailStr = depth == 0 ? "" : "└─"
        let details = "type: \(node.t), tag: \(node.tn ?? "N/A")"
        print("\(indent)\(tailStr) \(details)")

        // Print properties if they exist
        if let properties = node.p {
            print("\(indent)\(isTail ? "  " : "| ")   ├─ props: \(properties)")
        }
    }
}
