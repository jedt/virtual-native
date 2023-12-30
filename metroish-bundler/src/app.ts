"use strict";
import * as fn from "./functions";

export const renderApp = () => {
    const { h, ht } = fn.fnMap();
    return fn.mapToXML(
        h("body", {}, [
            h("div", {}, ht("View", "Hello, ")),
            h("div", {}, ht("View", "world.")),
            h("div", {}, h("div", {}, [ht("div", "foo"), ht("div", "bar")])),
        ]),
    );
};

const getRootNode = () => {
    const root = renderApp();
    return root;
};

console.log(getRootNode());
