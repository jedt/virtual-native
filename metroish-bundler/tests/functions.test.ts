import { describe, expect, it } from "@jest/globals";
import { List, Map } from "immutable";
import * as fn from "../src/functions";

describe("FunctionsTests", () => {
    it("shouldReturnTrue_hasTextTagEq", (done) => {
        const { hasTextTagEq } = fn.fnMap();
        expect(
            hasTextTagEq(
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "Hello, world",
                }),
            ),
        ).toBeTruthy();
        done();
    });
    it("shouldReturnTrue_hasTextTagEq", (done) => {
        const { hasTextTagEq } = fn.fnMap();
        expect(
            hasTextTagEq(
                Map({
                    tagName: "span",
                    props: Map({}),
                    children: "Hello, world",
                }),
            ),
        ).toBeFalsy();
        expect(hasTextTagEq(Map({}))).toBeFalsy();
        done();
    });
    it("shouldHasStringAsFirstChild", (done) => {
        const { hasStringAsFirstChildWithTextNode } = fn.fnMap();
        expect(
            hasStringAsFirstChildWithTextNode(
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "Hello, world",
                }),
            ),
        ).toBeTruthy();
        expect(
            hasStringAsFirstChildWithTextNode(
                Map({
                    tagName: "View",
                    props: Map({}),
                    children: List([
                        Map({
                            tagName: "Text",
                            props: Map({}),
                            children: "Hello, world",
                        }),
                    ]),
                }),
            ),
        ).toBeFalsy();
        done();
    });
    it("shouldProcessChildren_ListNode", (done) => {
        const { processListNode } = fn.fnMap();
        const listNode = List([
            Map({
                tagName: "Text",
                props: Map({}),
                children: "hello",
            }),
            Map({
                tagName: "Text",
                props: Map({}),
                children: "world",
            }),
        ]);

        const processed = processListNode(listNode);
        expect(List.isList(processed)).toBeTruthy();
        expect(processed).toEqual(
            List([
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "hello",
                }),
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "world",
                }),
            ]),
        );
        done();
    });
    it("shouldChildBeString_True", (done) => {
        const { shouldChildBeString } = fn.fnMap();
        const actual = shouldChildBeString("Text", ["hello"]);
        expect(actual).toBeTruthy();
        done();
    });

    it("shouldChildBeString_False", (done) => {
        const { shouldChildBeString } = fn.fnMap();
        const actual = shouldChildBeString("span", ["hello"]);
        expect(actual).toBeFalsy();
        done();
    });
    it("shouldProcessChildren_SingleNodeWithChildren", (done) => {
        const { processMapNode } = fn.fnMap();

        const singleNodeWithChildren = Map({
            tagName: "body",
            props: Map({}),
            children: List([
                Map({
                    tagName: "span",
                    props: Map({}),
                    children: "Hello, ",
                }),
                Map({
                    tagName: "strong",
                    props: Map({}),
                    children: "World",
                }),
            ]),
        });

        const processed = processMapNode(singleNodeWithChildren);
        expect(Map.isMap(processed)).toBeTruthy();
        expect(processed).toEqual(
            Map({
                tagName: "body",
                props: Map({}),
                children: List([
                    Map({
                        tagName: "span",
                        props: Map({}),
                        children: List([
                            Map({
                                tagName: "Text",
                                props: Map({}),
                                children: "Hello, ",
                            }),
                        ]),
                    }),
                    Map({
                        tagName: "strong",
                        props: Map({}),
                        children: List([
                            Map({
                                tagName: "Text",
                                props: Map({}),
                                children: "World",
                            }),
                        ]),
                    }),
                ]),
            }),
        );
        done();
    });
    it("shouldProcessChildren_SingleNodeWithText", (done) => {
        const { processMapNode } = fn.fnMap();

        const singleNode = Map({
            tagName: "span",
            props: Map({}),
            children: "Hello, ",
        });
        const processed = processMapNode(singleNode);
        expect(Map.isMap(processed)).toBeTruthy();
        expect(processed.get("tagName")).toEqual("span");
        expect(processed.get("children")).toEqual(
            List([
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "Hello, ",
                }),
            ]),
        );
        done();
    });

    it("shouldProcessChildren_SingleNodeWithChildrenMaps", (done) => {
        const { processMapNode } = fn.fnMap();

        const singleNodeWithChildMap = Map({
            tagName: "strong",
            props: Map({}),
            children: List([
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "Hello, World",
                }),
            ]),
        });

        const processed = processMapNode(singleNodeWithChildMap);
        expect(Map.isMap(processed)).toBeTruthy();
        expect(processed.get("tagName")).toEqual("strong");
        expect(processed.get("children")).toEqual(
            List([
                Map({
                    tagName: "Text",
                    props: Map({}),
                    children: "Hello, World",
                }),
            ]),
        );
        done();
    });

    it("shouldHandleIntentionalTextMaps", (done) => {
        const { processMapNode } = fn.fnMap();
        //const textNode = h("View", Map({}), "Hello, world.");
        const textNode = Map({
            tagName: "View",
            props: Map({}),
            children: "Hello, World",
        });
        const processed = processMapNode(textNode);
        expect(processed).toEqual(
            Map({
                tagName: "View",
                props: Map({}),
                children: List([
                    Map({
                        tagName: "Text",
                        props: Map({}),
                        children: "Hello, World",
                    }),
                ]),
            }),
        );
        done();
    });

    it("shouldHandleTextNodes", (done) => {
        const { processListNode } = fn.fnMap();
        const textNode = List([
            Map({
                tagName: "span",
                props: Map({}),
                children: "Hello, ",
            }),
            Map({
                tagName: "strong",
                props: Map({}),
                children: "World",
            }),
        ]);

        const processed = processListNode(textNode);
        expect(processed).toEqual(
            List([
                Map({
                    tagName: "span",
                    props: Map({}),
                    children: List([
                        Map({
                            tagName: "Text",
                            props: Map({}),
                            children: "Hello, ",
                        }),
                    ]),
                }),
                Map({
                    tagName: "strong",
                    props: Map({}),
                    children: List([
                        Map({
                            tagName: "Text",
                            props: Map({}),
                            children: "World",
                        }),
                    ]),
                }),
            ]),
        );
        done();
    });

    it("shouldHandleSingleNode_CustomTag", (done) => {
        const { h } = fn.fnMap();
        const testNode = h("span", Map({}), "hello");
        expect(testNode).toEqual(
            Map({
                tagName: "span",
                props: Map({}),
                children: List([
                    Map({
                        tagName: "Text",
                        props: Map({}),
                        children: "hello",
                    }),
                ]),
            }),
        );
        done();
    });

    it("shouldHandleChildren_singleNodeWithListNode", (done) => {
        const { h } = fn.fnMap();
        const listNode = h(
            "body",
            Map({}),
            List([h("Text", Map({}), "hello"), h("Text", Map({}), "world")]),
        );
        const children = listNode.get("children");
        expect(children.size).toEqual(1);
        const items = children.get(0);
        expect(items.get(0)).toEqual(
            Map({
                tagName: "Text",
                props: Map({}),
                children: "hello",
            }),
        );
        expect(items.get(1)).toEqual(
            Map({
                tagName: "Text",
                props: Map({}),
                children: "world",
            }),
        );

        done();
    });

    it("shouldHandleListOfChildrenOFText", (done) => {
        const { h } = fn.fnMap();
        const bodyMap = h(
            "body",
            Map({}),
            List([
                h("span", Map({}), "Hello, "),
                h("strong", Map({}), "World"),
            ]),
        );

        expect(bodyMap.get("tagName")).toEqual("body");
        const children = bodyMap.get("children");
        expect(children.size).toEqual(1);
        const list = children.get(0);
        expect(list.size).toEqual(2);
        expect(list.get(0)).toEqual(
            Map({
                tagName: "span",
                props: Map({}),
                children: List([
                    Map({
                        tagName: "Text",
                        props: Map({}),
                        children: "Hello, ",
                    }),
                ]),
            }),
        );
        expect(list.get(1)).toEqual(
            Map({
                tagName: "strong",
                props: Map({}),
                children: List([
                    Map({
                        tagName: "Text",
                        props: Map({}),
                        children: "World",
                    }),
                ]),
            }),
        );

        done();
    });

    it("shouldCreateElementText", (done) => {
        const { ht } = fn.fnMap();
        const testNode = ht("Text", "Hello");

        const output = fn.mapToXML(testNode);
        expect(output).toEqual("<Text>Hello</Text>");
        done();
    });
});
