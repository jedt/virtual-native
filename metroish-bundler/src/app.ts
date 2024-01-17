"use strict";
import * as fn from "./functions";
const { evalAllNodesWithFunctions } = fn.parseFunctionsFnMap();
const { h, ht } = fn.fnMap();

const renderApp = () => {
    const touchableCallback = function () {
        return Math.PI;
    };

    return h("bodyOfTwo", {}, [
        h("divTargetLeft", {}, ht("View", "TargetLeft")),
        h(
            "divTarget",
            {},
            h("View", {}, [
                h("touchable", { onPress: touchableCallback }),
                ht("View", "Sibling one"),
            ]),
        ),
        h("divTargetRight", {}, ht("View", "TargetRight")),
    ]);
};

export const getRootNode = () => {
    const root = renderApp();
    return JSON.stringify(evalAllNodesWithFunctions(root));
};

// Assign getRootNode to the global object
(globalThis as Global)["getRootNode"] = getRootNode;

getRootNode();
