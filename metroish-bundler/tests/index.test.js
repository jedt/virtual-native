"use strict";
import { Map, List } from "immutable";
import { describe, expect, it } from "@jest/globals";
import { testFnList, fnMap, mapToXML } from "../src/core.js";

describe("coreTests", () => {
  it("should pass tests", (done) => {
    const { mkCounter, schematize } = testFnList();
    const counter = mkCounter(schematize({ starting: 10 }));
    expect(counter.increment()).toEqual(11);
    done();
  });

  it("shouldFirstChild_hasStringAsFirstChild", (done) => {
    const { hasStringAsFirstChild } = fnMap();
    const testNode = Map({
      tagName: "Text",
      props: Map({}),
      children: "Hello, world",
    });

    expect(hasStringAsFirstChild(testNode)).toEqual(true);
    done();
  });

  it("shouldNotFirstChild_hasStringAsFirstChild", (done) => {
    const { hasStringAsFirstChild } = fnMap();
    const testNode = Map({
      tagName: "View",
      props: Map({}),
      children: List([
        Map({
          tagName: "Text",
          props: Map({}),
          children: "Hello, world",
        }),
      ]),
    });

    expect(hasStringAsFirstChild(testNode)).toEqual(false);
    done();
  });

  it("shouldNotFirstChild_hasStringAsFirstChild", (done) => {
    const { hasStringAsFirstChild } = fnMap();
    const testNode = Map({
      tagName: "span",
      props: Map({}),
      children: "Hello, World",
    });

    expect(hasStringAsFirstChild(testNode)).toEqual(false);
    done();
  });

  it("shouldNotFirstChild_hasStringAsFirstChild_null", (done) => {
    const { hasStringAsFirstChild } = fnMap();
    expect(hasStringAsFirstChild(null)).toEqual(false);
    done();
  });

  it("shouldNotListize_Lists", (done) => {
    const { listize } = fnMap();
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
    const listized = listize(listNode);
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
    const { listize } = fnMap();
    const listized = listize(["hi"]);
    expect(listized.size).toEqual(1);
    expect(listized.get(0)).toEqual("hi");
    done();
  });

  it("shouldListize_Arrays", (done) => {
    const { listize } = fnMap();
    const listNode = [
      Map({
        tagName: "Text",
        props: Map({}),
        children: "hello",
      }),
    ];
    const listized = listize(listNode);
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

  it("shouldSchematizeMaps", (done) => {
    const { h, nodeSchematizer } = fnMap();
    const span = h("span", Map({}), "Hello, ");
    nodeSchematizer(span);
    done();
  });

  it("shouldSchematizeTextMaps", (done) => {
    const { nodeSchematizer } = fnMap();
    const textNode = Map({
      tagName: "Text",
      props: Map({}),
      children: "Hello, world",
    });
    nodeSchematizer(textNode);
    done();
  });

  it("shouldProcessChildren_ListNode", (done) => {
    const { processListNode } = fnMap();
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
  it("shouldHandleSingleNode_Text", (done) => {
    const { h } = fnMap();
    const testNode = h("Text", Map({}), "hello");
    expect(testNode).toEqual(
      Map({
        tagName: "Text",
        props: Map({}),
        children: "hello",
      }),
    );
    done();
  });

  it("shouldChildBeString_True", (done) => {
    const { shouldChildBeString } = fnMap();
    const actual = shouldChildBeString("Text", ["hello"]);
    expect(actual).toBeTruthy();
    done();
  });

  it("shouldChildBeString_False", (done) => {
    const { shouldChildBeString } = fnMap();
    const actual = shouldChildBeString("span", ["hello"]);
    expect(actual).toBeFalsy();
    done();
  });

  it("shouldHandleSingleNode_CustomTag", (done) => {
    const { h } = fnMap();
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
    const { h } = fnMap();
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
  it("shouldProcessChildren_SingleNodeWithChildren", (done) => {
    const { processMapNode } = fnMap();

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
    const { processMapNode } = fnMap();

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
    const { processMapNode } = fnMap();

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
    const { h, processMapNode } = fnMap();
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
    const { processListNode } = fnMap();
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

  it("shouldHandleListOfChildrenOFText", (done) => {
    const { h } = fnMap();
    const bodyOfText = h(
      "body",
      Map({}),
      List([h("span", Map({}), "Hello, "), h("strong", Map({}), "World")]),
    );
    expect(bodyOfText).toEqual(
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
    //console.log(mapToXML(bodyOfText));
    done();
  });

  it("shouldCreateElement", (done) => {
    const { h } = fnMap();
    const elementJson = h(
      "div",
      { id: "root" },
      h(
        "body",
        Map({}),
        List([h("span", Map({}), "Hello, "), h("strong", Map({}), "World")]),
      ),
      "!",
      h("p", Map({}), "This is a paragraph."),
    );
    console.log(mapToXML(elementJson));
    done();
  });
});
