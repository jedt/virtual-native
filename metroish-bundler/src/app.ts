"use strict";
import * as fn from "./functions";

const renderApp = () => {
    const touchableCallback = function () {
        console.log("hello, world");
    };

    const { h, ht } = fn.fnMap();
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
    return JSON.stringify(root);
};

global.getRootNode = getRootNode;
