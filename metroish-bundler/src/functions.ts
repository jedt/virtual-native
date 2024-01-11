import { List, Map } from "immutable";
import * as utils from "./utils";
import { NodeMapType } from "./utils";

export function fnMap(): any {
    const processListNode = (listNode: any): any => {
        if (!List.isList(listNode)) {
            throw Error(`not a list ${listNode}`);
        }

        return listNode.map((item) => {
            if (List.isList(item)) {
                return processListNode(item);
            } else if (Map.isMap(item)) {
                return processMapNode(item as NodeMapType);
            } else if (Array.isArray(item)) {
                return processListNode(utils.createListFromArray(item));
            } else if (typeof item === "string") {
                return utils.createTextMapNodeFromString(item);
            } else {
                throw Error(`Unexpected string type of child ${listNode}`);
            }
        });
    };

    function processMapNode(node: NodeMapType): NodeMapType {
        if (utils.hasStringAsFirstChildWithTextNode(node)) {
            return node;
        } else {
            if (Map.isMap(node)) {
                const children = utils.childrenFromMapNode(node);
                if (List.isList(children)) {
                    //process each childrenFromMapNodes using tail recursion
                    return node.set(
                        "children",
                        processListNode(children),
                    ) as NodeMapType;
                } else {
                    //child is not a list
                    if (typeof children === "string") {
                        return node.set(
                            "children",
                            utils.createListFromString(children),
                        ) as NodeMapType;
                    }
                }
            } else if (typeof node === "string") {
                throw new Error('Unexpected type of child: "string"');
            }
        }
    }

    function processChildrenWithTagName(tagName: string, children: any): any {
        const shouldCreateTextNodeBecauseTagNameIsNotText = (
            tagName: string,
            item: any,
        ) => {
            if (typeof item === "string" && tagName !== utils.tagNameText) {
                return true;
            } else {
                return false;
            }
        };

        const childrenCopy = children.map((item: any) => {
            if (shouldCreateTextNodeBecauseTagNameIsNotText(tagName, item)) {
                return utils.createTextMapNodeFromString(item);
            } else {
                return utils.listize(item);
            }
        });
        return processChildren(childrenCopy);
    }

    function processChildren(node: any): any {
        if (Map.isMap(node)) {
            return processMapNode(node as NodeMapType);
        } else if (List.isList(node)) {
            return processListNode(node);
        } else {
            return utils.defaultNode(node);
        }
    }

    function ht(tagName: string, ...children: any): NodeMapType {
        return h(tagName, Map({}), ...children);
    }

    function h(tagName: string, props: any, ...children: any): NodeMapType {
        const childrenFn = (tagName: string, children: any): any => {
            if (
                utils.shouldChildBeStringAndNotCreateNewNode(tagName, children)
            ) {
                return children[0];
            } else {
                const listized = utils.listize(children);
                return processChildrenWithTagName(tagName, listized);
            }
        };
        return Map({
            tagName: tagName,
            props: Map(props || {}),
            children: childrenFn(tagName, children),
        });
    }

    return {
        listize: utils.listize,
        shouldChildBeStringAndNotCreateNewNode:
            utils.shouldChildBeStringAndNotCreateNewNode,
        h,
        ht,
        processListNode,
        processMapNode,
        hasStringAsFirstChildWithTextNode:
            utils.hasStringAsFirstChildWithTextNode,
        hasTextTagEq: utils.hasTextTagEq,
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
    if (utils.hasStringAsFirstChildWithTextNode(node)) {
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
