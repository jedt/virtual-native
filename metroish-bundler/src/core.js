"use strict";
import { List, Map, fromJS } from "immutable";
import Joi from "joi";

// curry :: ((a, b, ...) -> c) -> a -> b -> ... -> c
const compose =
  (...fns) =>
  (...args) =>
    fns.reduceRight((res, fn) => [fn.call(null, ...res)], args)[0];
//
// const toUpperCase = x => x.toUpperCase();
// const exclaim = x => `${x}!`;
// const shout = compose(exclaim, toUpperCase);
//
// shout('send in the clowns'); // "SEND IN THE CLOWNS!"

const tagtxt = (tagName) => tagName && tagName === "Text";
const listize = (items) => {
  if (!List.isList(items) && Array.isArray(items)) {
    return List(items);
  } else {
    return items;
  }
};

/**
 * checks if the object is String
 * @param o
 * @returns {boolean}
 */
const objs = (o) => typeof o === "string";

/**
 * Higher-order function to create a validator function for a given Joi schema.
 * @param {Object} param - The Joi schema to use for validation.
 * @returns {Function} A function that takes an object to validate against the schema.
 */
function schematizer(param) {
  return function (data) {
    // Convert Immutable.js Maps to regular objects
    const plainData = Map.isMap(data) ? data.toJS() : data;

    // Validate the plain object
    const { error } = Joi.object(param).validate(plainData, {
      allowUnknown: true,
      abortEarly: false,
    });

    if (error) {
      throw new Error(`Validation Error: ${error.message}`);
    }

    // Return the original Immutable.js Map
    return data;
  };
}

function fnMap() {
  const nodeSchematizer = schematizer({
    tagName: Joi.string().required(),
    props: [Joi.object().pattern(Joi.string(), Joi.any())],
    children: Joi.any(),
  });

  const shouldChildBeString = (tagName, children) => {
    const singleChNode = (children) =>
      children?.length === 1 ? children : null;
    const stringType = (children) => typeof children[0] === "string";

    const hasSingleStr = compose(stringType, singleChNode);
    return tagtxt(tagName) && hasSingleStr(children);
  };

  function h(tagName, props, ...children) {
    return Map({
      tagName: tagName,
      props: Map(props || {}),
      children: shouldChildBeString(tagName, children)
        ? children[0]
        : processChildrenWithTagName(tagName, listize(children)),
    });
  }

  function processListNode(listNode) {
    if (!List.isList(listNode)) throw new Error("Not a list");
    const copyOfNode = listNode.map((item) => {
      if (List.isList(item)) {
        //process each child using tail recursion
        return processChildren(item);
      } else if (Map.isMap(item)) {
        return processMapNode(item);
      } else if (Array.isArray(item)) {
        return processChildren(List(item));
      } else if (objs(item)) {
        throw new Error(`Unexpected string type of child: ${item}`);
      } else {
        throw new Error(`Unexpected type of child: ${typeof item}`);
      }
    });

    return copyOfNode;
  }

  function hasStringAsFirstChild(node) {
    const hasTag = (node, tag) =>
      Map.isMap(node) && node.get("tagName") === tag;
    const hasTextTag = (node) => (hasTag(node, "Text") ? node : null);
    const hasChildAndStringType = (node) =>
      !!(node?.get("children") && typeof node?.get("children") === "string");
    return compose(hasChildAndStringType, hasTextTag)(node);
  }

  function processMapNode(node) {
    if (hasStringAsFirstChild(node)) {
      return node;
    } else {
      if (Map.isMap(node)) {
        const childrenFromMapNodes = node.get("children");
        if (List.isList(childrenFromMapNodes)) {
          //process each childrenFromMapNodes using tail recursion
          return node.set("children", processListNode(childrenFromMapNodes));
        } else {
          //child is not a list
          if (objs(childrenFromMapNodes)) {
            return node.set(
              "children",
              List([
                Map({
                  tagName: "Text",
                  props: Map({}),
                  children: childrenFromMapNodes,
                }),
              ]),
            );
          }
        }
      } else if (typeof node === "string") {
        throw new Error('Unexpected type of child: "string"');
      }
    }
  }

  function processChildrenWithTagName(tagName, children) {
    const shouldNode = (tagName, item) => objs(item) && !tagtxt(tagName);
    const childrenCopy = children.map((item) => {
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

  function processChildren(node) {
    if (Map.isMap(node)) {
      return processMapNode(node);
    } else if (List.isList(node)) {
      return processListNode(node);
    } else {
      return Map({
        tagName: "Text",
        props: Map({}),
        children: List([node]),
      });
    }
  }

  return {
    h,
    nodeSchematizer,
    listize,
    processChildren,
    processMapNode,
    processListNode,
    hasStringAsFirstChild,
    shouldChildBeString,
  };
}

function testFnList() {
  const schematize = schematizer({
    timer: Joi.number(),
  });

  const mkCounter = ({ starting }) => {
    const validationResult = schematize({ starting });
    if (validationResult.error) {
      throw new Error(
        `Invalid starting value: ${validationResult.error.message}`,
      );
    }

    let count = starting;

    function increment() {
      count++;
      return count;
    }

    function reset() {
      count = 0;
      console.log("Counter reset.");
    }

    return { increment, reset };
  };

  return { mkCounter, schematize };
}

function listToXML(node) {
  let xmlString = "";
  node.forEach((item) => {
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
function mapToXML(node) {
  // Handling text nodes
  if (node.get("tagName") === "Text") {
    const children = node.get("children");
    if (children.size === 1 && typeof children.get(0) === "string") {
      const tagName = node.get("tagName");
      let xmlStringTextView = `<${tagName}`;
      if (children && children.size > 0) {
        // Add attributes (props) to the tag
        const textProps = node.get("props");
        if (textProps) {
          textProps.forEach((value, key) => {
            xmlStringTextView += ` ${key}="${value}"`;
          });
        }
        xmlStringTextView += `>${children.get(0)}`;
      }
      xmlStringTextView += `</${tagName}>`;
      return xmlStringTextView;
    }
  }

  // Construct the start of the XML tag
  const tagName = node.get("tagName");
  let xmlString = `<${tagName}`;

  // Add attributes (props) to the tag
  const props = node.get("props");
  if (props) {
    props.forEach((value, key) => {
      xmlString += ` ${key}="${value}"`;
    });
  }

  // Close the opening tag
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

  // Construct the closing tag
  xmlString += `</${tagName}>`;

  return xmlString;
}

export { fnMap, testFnList, mapToXML };
