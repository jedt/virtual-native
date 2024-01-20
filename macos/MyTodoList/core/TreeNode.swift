import Foundation

struct Props: Codable {
    var style: [String: CGFloat]?
    var onPress: String?
    var id: Int?
    var bridgeID: String?

    private enum CodingKeys: String, CodingKey {
        case style, onPress, id, bridgeID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try? container.decode([String: CGFloat].self, forKey: .style)
        onPress = try? container.decode(String.self, forKey: .onPress)
        id = try? container.decode(Int.self, forKey: .id)
        bridgeID = try? container.decode(String.self, forKey: .bridgeID)
    }
}

enum NodeChildren: Codable {
    case nodes([TNode]) // contains a list of objects
    case text(String)
    case nestedNodes([[TNode]]) // contains a list of lists

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
            return
        }
        if let nodes = try? container.decode([TNode].self) {
            self = .nodes(nodes)
            return
        }
        if let nestedNodes = try? container.decode([[TNode]].self) {
            self = .nestedNodes(nestedNodes)
            return
        }
        throw DecodingError.typeMismatch(
            NodeChildren.self,
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode NodeChildren")
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .nodes(let nodes):
                try container.encode(nodes)
            case .text(let text):
                try container.encode(text)
            case .nestedNodes(let nestedNodes):
                try container.encode(nestedNodes)
        }
    }
}

struct TNode: Codable {
    let tagName: String
    let props: Props
    let children: NodeChildren

    enum CodingKeys: String, CodingKey {
        case tagName
        case props
        case children
    }
}

extension TNode {
    func getChildren() -> [TNode] {
        switch children {
            case .nodes(let children):
                // Direct list of children nodes
                return children

            case .nestedNodes(let nestedChildren):
                // Flatten the list of lists into a single list
                return nestedChildren.flatMap { $0 }

            case .text:
                // No TNode children in this case
                return []
        }
    }
}

func parseJSONStringToTree(_ jsonString: String) throws -> TNode {
    let jsonData = Data(jsonString.utf8)
    let decoder = JSONDecoder()

    let rootNode: TNode = try decoder.decode(TNode.self, from: jsonData)
    return rootNode
}

func dictionaryFromTNode(_ node: TNode) -> [String: Any] {
    let tagName: String = node.tagName
    let props: [String: Any] = getPropsDictionary(node)

    return [
        "tagName": tagName,
        "props": props.isEmpty ? "Props()" : props,
        "children": getChildrenArrayContainer(node.children),
    ]
}

func getPropsDictionary(_ node: TNode) -> [String: Any] {
    var propsDict = [String: Any]()

    if let style = node.props.style {
        let styleDict = style.reduce(into: [String: Any]()) { dict, styleEntry in
            dict[styleEntry.key] = styleEntry.value
        }
        propsDict["style"] = styleDict
    }

    if let onPress = node.props.onPress {
        propsDict["onPress"] = onPress
    }

    if let id = node.props.id {
        propsDict["id"] = id
    }

    if let bridgeID = node.props.bridgeID {
        propsDict["bridgeID"] = bridgeID
    }

    return propsDict
}


func setPropsDictionary(originalDict: [String: Any], key: String, value: Any) -> [String: Any] {
    // Creating a copy of the original dictionary
    var modifiedDict = originalDict

    // Set or update the value for the specified key
    modifiedDict[key] = value

    return modifiedDict
}

func getChildrenNodesFromTNode(_ node: TNode) -> [Any] {
    switch node.children {
        case .nodes(let children):
            // Direct list of children nodes
            return children

        case .nestedNodes(let nestedChildren):
            // Flatten the list of lists into a single list
            return nestedChildren.compactMap { node in
                node.map { dictionaryFromTNode($0) }
            }

        case .text:
            // No TNode children in this case
            return []
    }
}
