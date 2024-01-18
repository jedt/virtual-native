"use strict";
import * as fn from "./functions";
const { evalAllNodesWithFunctions, invokeExposedJsFn } =
    fn.parseFunctionsFnMap();
const { h, ht } = fn.fnMap();

const renderApp = () => {
    const touchableMathCallback = function () {
        return Math.PI;
    };

    const touchableFooCallback = function () {
        return "## bar ##";
    };

    return h("bodyOfTwo", {}, [
        h("divTargetLeft", {}, ht("View", "TargetLeft")),
        h(
            "divTarget",
            {},
            h("View", {}, [
                h("touchable", { onPress: touchableFooCallback }),
                h("touchable", { onPress: touchableMathCallback }),
                ht("View", "Sibling one"),
            ]),
        ),
        h("divTargetRight", {}, ht("View", "TargetRight")),
    ]);
};

export const getRootNode = () => {
    const app = renderApp();
    return JSON.stringify(evalAllNodesWithFunctions("app", app));
};

// Assign getRootNode to the global object
(globalThis as Global)["getRootNode"] = getRootNode;
(globalThis as Global)["invokeExposedJsFn"] = invokeExposedJsFn;

// getRootNode();
// console.log(invokeExposedJsFn("app.4.onPress"));
