import { List, Map } from "immutable";

const tagNameText = "Text";

type NodeMapType = Map<string, any>;

function listize(items: any): List<any> {
    if (!List.isList(items) && Array.isArray(items)) {
        return List(items);
    } else {
        return items;
    }
}
function defaultNode(node: ArrayLike<any>): NodeMapType {
    return Map({
        tagName: "Text",
        props: Map({}),
        children: List([node]),
    });
}

function mapNotEmpty(node: NodeMapType): boolean {
    return node?.size > 0;
}

function hasTextTagEq(node: NodeMapType): boolean {
    if (mapNotEmpty(node) && node.has("tagName")) {
        return node.get("tagName") == tagNameText;
    }
    return false;
}

function childrenFromMapNode(node: any): any {
    if (mapNotEmpty(node) && node.has("children")) {
        return node.get("children");
    }
}

function hasStringAsFirstChildWithTextNode(node: NodeMapType): boolean {
    if (mapNotEmpty(node) && node.has("children")) {
        if (hasTextTagEq(node)) {
            const children = childrenFromMapNode(node);
            if (typeof children === "string") {
                return true;
            }
        }
    }

    return false;
}
export function fnMap(): any {
    function createListFromString(children: string): List<NodeMapType> {
        return List<NodeMapType>([
            Map({
                tagName: "Text",
                props: Map({}),
                children: children,
            }),
        ]);
    }

    function createListFromArray(
        children: ArrayLike<NodeMapType>,
    ): List<NodeMapType> {
        return List<any>([
            Map({
                tagName: "Text",
                props: Map({}),
                children: children,
            }),
        ]);
    }

    const processListNode = (listNode: any): any => {
        if (!List.isList(listNode)) {
            throw Error(`not a list ${listNode}`);
        }

        return listNode.map((item) => {
            if (List.isList(item)) {
                return processListNode(item);
            } else if (Map.isMap(item)) {
                return processMapNode(item);
            } else if (Array.isArray(item)) {
                return processListNode(createListFromArray(item));
            } else if (typeof item === "string") {
                throw Error(`Unexpected string type of child ${listNode}`);
            } else {
                throw Error(`Unexpected string type of child ${listNode}`);
            }
        });
    };

    function processMapNode(node: any): any {
        if (hasStringAsFirstChildWithTextNode(node)) {
            return node;
        } else {
            if (Map.isMap(node)) {
                const children = childrenFromMapNode(node);
                if (List.isList(children)) {
                    //process each childrenFromMapNodes using tail recursion
                    return node.set("children", processListNode(children));
                } else {
                    //child is not a list
                    if (typeof children === "string") {
                        return node.set(
                            "children",
                            createListFromString(children),
                        );
                    }
                }
            } else if (typeof node === "string") {
                throw new Error('Unexpected type of child: "string"');
            }
        }
    }

    function isSizeOneArray(children: any): boolean {
        return Array.isArray(children) && children.length > 0;
    }

    function isFirstItemString(children: any): boolean {
        return Array.isArray(children) && typeof children[0] === "string";
    }

    const shouldChildBeString = (tagName: string, children: any): boolean => {
        return (
            tagName === tagNameText &&
            isSizeOneArray(children) &&
            isFirstItemString(children)
        );
    };

    function processChildrenWithTagName(tagName: string, children: any): any {
        const shouldNode = (tagName: string, item: any) =>
            typeof item === "string" && tagName !== tagNameText;

        const childrenCopy = children.map((item: any) => {
            if (shouldNode(tagName, item)) {
                return Map({
                    tagName: "Text",
                    props: Map({}),
                    children: item,
                });
            } else {
                return item;
            }
        });
        return processChildren(childrenCopy);
    }

    function processChildren(node: any): any {
        if (Map.isMap(node)) {
            return processMapNode(node);
        } else if (List.isList(node)) {
            return processListNode(node);
        } else {
            return defaultNode(node);
        }
    }

    function ht(tagName: string, ...children: any): any {
        return h(tagName, Map({}), ...children);
    }

    function h(tagName: string, props: any, ...children: any): any {
        const childrenFn = (tagName: string, children: any): any => {
            if (shouldChildBeString(tagName, children)) {
                return children[0];
            } else {
                return processChildrenWithTagName(tagName, listize(children));
            }
        };
        return Map({
            tagName: tagName,
            props: Map(props || {}),
            children: childrenFn(tagName, children),
        });
    }

    return {
        shouldChildBeString,
        h,
        ht,
        processListNode,
        processMapNode,
        hasStringAsFirstChildWithTextNode,
        hasTextTagEq,
    };
}
function listToXML(node: any): string {
    let xmlString = "";
    node.forEach((item: any) => {
        if (List.isList(item)) {
            xmlString += listToXML(item);
        } else if (Map.isMap(item)) {
            xmlString += mapToXML(item);
        } else if (typeof item === "string") {
            return item;
        } else {
            throw new Error(`Unexpected type of child: ${typeof item}`);
        }
    });
    return xmlString;
}

export function mapToXML(node: any): string {
    // Handling text nodes
    if (hasStringAsFirstChildWithTextNode(node)) {
        const childNodeText = node.get("children");
        const tagName = node.get("tagName");
        let xmlStringTextView = `<${tagName}`;

        const textProps = node.get("props");
        if (textProps) {
            textProps.forEach((value: any, key: string) => {
                xmlStringTextView += ` ${key}="${value}"`;
            });
        }
        xmlStringTextView += `>${childNodeText}`;

        xmlStringTextView += `</${tagName}>`;
        return xmlStringTextView;
    }

    const tagName = node.get("tagName");
    let xmlString = `<${tagName}`;

    const props = node.get("props");
    if (props) {
        props.forEach((value: any, key: string) => {
            xmlString += ` ${key}="${value}"`;
        });
    }

    xmlString += ">";

    // Process children
    const children = node.get("children");
    if (children && children.size > 0) {
        if (List.isList(children)) {
            xmlString += listToXML(children);
        } else {
            throw new Error("unexpected type");
        }
    }

    //closing tag
    xmlString += `</${tagName}>`;

    return xmlString;
}
export function main(): any {
    const testMap = Map({});
    console.log("hello, map", testMap);
}
