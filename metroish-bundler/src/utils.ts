import { List, Map } from "immutable";
export const tagNameText = "Text";
export type NodeMapType = Map<string, any>;

export function listize(items: any): List<any> {
    if (!List.isList(items) && Array.isArray(items)) {
        return List(items);
    } else {
        return items;
    }
}
export function defaultNode(node: ArrayLike<any>): NodeMapType {
    return Map({
        tagName: "Text",
        props: Map({}),
        children: List([node]),
    });
}
export function createTextMapNodeFromString(str: string): NodeMapType {
    return Map({
        tagName: "Text",
        props: Map({}),
        children: str,
    });
}

export function mapNotEmpty(node: NodeMapType): boolean {
    return node?.size > 0;
}

export function childrenFromMapNode(node: any): any {
    if (mapNotEmpty(node) && node.has("children")) {
        return node.get("children");
    }
}
export function hasTextTagEq(node: NodeMapType): boolean {
    if (mapNotEmpty(node) && node.has("tagName")) {
        return node.get("tagName") == tagNameText;
    }
    return false;
}
export function hasStringAsFirstChildWithTextNode(node: NodeMapType): boolean {
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
export function createListFromString(children: string): List<NodeMapType> {
    return List<NodeMapType>([
        Map({
            tagName: "Text",
            props: Map({}),
            children: children,
        }),
    ]);
}

export function createListFromArray(
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
export function isSizeOneArray(children: any): boolean {
    return Array.isArray(children) && children.length > 0;
}

export function isFirstItemString(children: any): boolean {
    return Array.isArray(children) && typeof children[0] === "string";
}

export function shouldChildBeStringAndNotCreateNewNode(
    tagName: string,
    children: ArrayLike<any>,
): boolean {
    if (tagName === tagNameText && isSizeOneArray(children)) {
        return isFirstItemString(children);
    }

    return false;
}
