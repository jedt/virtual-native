"use strict";
import * as fn from "./functions";
const { evalAllNodesWithFunctions, invokeExposedJsFn } =
    fn.parseFunctionsFnMap();
const { h, ht } = fn.fnMap();

const renderApp = () => {
    const touchableFooCallback = function () {
        return "## bar ##";
    };

    const asyncCallback = function () {
        Math.PI;
    };

    return h("bodyOfTwo", {}, [
        h("divTargetLeft", {}, ht("View", "TargetLeft")),
        h(
            "divTarget",
            {},
            h("View", {}, [
                h("NSButton", { onPress: touchableFooCallback }),
                h("NSButton", { onPress: asyncCallback }),
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

(globalThis as Global)["getRootNode"] = getRootNode;
(globalThis as Global)["invokeExposedJsFn"] = invokeExposedJsFn;
