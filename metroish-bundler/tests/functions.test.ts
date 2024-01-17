import { describe, expect, it } from "@jest/globals";
import { List, Map } from "immutable";
import * as fn from "../src/functions";

describe("FunctionsTests", () => {
    it("shouldParseNodeMap_WithSerializedFunction", (done) => {
        const { evalAllNodesWithFunctions } = fn.parseFunctionsFnMap();
        const { h } = fn.fnMap();
        function callbackFoo() {
            return "foobar";
        }

        const bodyMap = h(
            "body",
            Map({ foo: "bar" }),
            List([
                h(
                    "span",
                    Map({
                        onCallback_shouldParseNodeMap_WithSerializedFunction:
                            callbackFoo,
                    }),
                    "Hello, ",
                ),
            ]),
        );

        const jsonString = JSON.stringify(evalAllNodesWithFunctions(bodyMap));
        expect(
            (globalThis as Global)[
                "onCallback_shouldParseNodeMap_WithSerializedFunction"
            ](),
        ).toEqual("foobar");
        done();
    });

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

    it("shouldHandleSingleNode_Text", (done) => {
        const { h } = fn.fnMap();
        const testNode = h("Text", Map({}), "hello");
        expect(testNode).toEqual(
            Map({
                tagName: "Text",
                props: Map({ id: 1 }),
                children: "hello",
            }),
        );
        done();
    });

    it("shouldNotListize_Lists", (done) => {
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
        const listized = fn.fnMap().listize(listNode);
        expect(listized.size).toEqual(2);
        expect(listized.get(0)).toEqual(
            Map({
                tagName: "Text",
                props: Map({}),
                children: "hello",
            }),
        );
        expect(listized.get(1)).toEqual(
            Map({
                tagName: "Text",
                props: Map({}),
                children: "world",
            }),
        );
        done();
    });

    it("shouldListize_ArraysPrimitive", (done) => {
        const listized = fn.fnMap().listize(["hi"]);
        expect(listized.size).toEqual(1);
        expect(listized.get(0)).toEqual("hi");
        done();
    });

    it("shouldListize_Arrays", (done) => {
        const listNode = [
            Map({
                tagName: "Text",
                props: Map({}),
                children: "hello",
            }),
        ];
        const listized = fn.fnMap().listize(listNode);
        expect(listized.size).toEqual(1);
        expect(listized.get(0)).toEqual(
            Map({
                tagName: "Text",
                props: Map({}),
                children: "hello",
            }),
        );
        done();
    });

    it("shouldProcessChildren_Array", (done) => {
        const { h } = fn.fnMap();
        const testNode = h("span", Map({}), ["hello"]);
        expect(Map.isMap(testNode)).toBeTruthy();
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
        const { shouldChildBeStringAndNotCreateNewNode } = fn.fnMap();
        const actual = shouldChildBeStringAndNotCreateNewNode("Text", [
            "hello",
        ]);
        expect(actual).toBeTruthy();
        done();
    });

    it("shouldChildBeString_False", (done) => {
        const { shouldChildBeStringAndNotCreateNewNode } = fn.fnMap();
        const actual = shouldChildBeStringAndNotCreateNewNode("span", [
            "hello",
        ]);
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
                props: Map({ foo: "bar" }),
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
                    props: Map({
                        foo: "bar",
                    }),
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
        const handleFoo = function () {
            console.log("bar");
        };

        const testNode = h("span", Map({ foo: handleFoo }), "hello");
        expect(testNode).toEqual(
            Map({
                tagName: "span",
                props: Map({
                    foo: 'function () {\n            console.log("bar");\n        }',
                    id: 1,
                }),
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
        const listNode = h("body", Map({}), [
            h("Text", Map({}), "hello"),
            h("Text", Map({}), "world"),
        ]);
        const children = listNode.get("children");
        expect(children.size).toEqual(1);
        const items = children.get(0);
        expect(items.get(0)).toEqual(
            Map({
                tagName: "Text",
                props: Map({
                    id: 1,
                }),
                children: "hello",
            }),
        );
        expect(items.get(1)).toEqual(
            Map({
                tagName: "Text",
                props: Map({
                    id: 2,
                }),
                children: "world",
            }),
        );

        done();
    });

    it("shouldHandleListOfChildrenOFText", (done) => {
        const { evalAllNodesWithFunctions } = fn.parseFunctionsFnMap();
        const { h } = fn.fnMap();
        function callbackFoo() {
            return "callback";
        }

        function callbackBody() {
            return "callbackBody_shouldHandleListOfChildrenOFText";
        }
        const bodyMap = h(
            "body",
            Map({ foo: "bar", onPressBody: callbackBody }),
            List([
                h("span", Map({ onPress: callbackFoo }), "Hello, "),
                h("strong", Map({}), "World"),
            ]),
        );

        expect(bodyMap.get("tagName")).toEqual("body");
        const bodyProps = bodyMap.get("props");
        expect(bodyProps.get("foo")).toEqual("bar");
        expect(bodyProps.get("onPressBody")).toEqual(`function callbackBody() {
            return "callbackBody_shouldHandleListOfChildrenOFText";
        }`);
        const children = bodyMap.get("children");
        expect(children.size).toEqual(1);
        const list = children.get(0);
        expect(list.size).toEqual(2);
        expect(list.get(0)).toEqual(
            Map({
                tagName: "span",
                props: Map({
                    onPress: `function callbackFoo() {
            return "callback";
        }`,
                    id: 1,
                }),
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
                props: Map({ id: 2 }),
                children: List([
                    Map({
                        tagName: "Text",
                        props: Map({}),
                        children: "World",
                    }),
                ]),
            }),
        );

        evalAllNodesWithFunctions(bodyMap);

        expect((globalThis as Global)["onPressBody"]()).toEqual(
            "callbackBody_shouldHandleListOfChildrenOFText",
        );

        expect((globalThis as Global)["onPress"]()).toEqual("callback");
        done();
    });

    it("shouldCreateElementText", (done) => {
        const { ht } = fn.fnMap();
        const testNode = ht("Text", "Hello");

        const output = fn.mapToXML(testNode);
        expect(output).toEqual('<Text id="1">Hello</Text>');
        done();
    });

    it("shouldCreateElement_BodyWithLists", (done) => {
        const { ht } = fn.fnMap();
        const testNode = ht(
            "body",
            List([ht("View", "Hello, "), ht("View", "World")]),
        );

        const output = fn.mapToXML(testNode);
        expect(output).toEqual(
            '<body id="3"><View id="1"><Text>Hello, </Text></View><View id="2"><Text>World</Text></View></body>',
        );
        done();
    });
});
