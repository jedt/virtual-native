"use strict";
import * as fn from "./functions";

const renderApp = () => {
    const { h, ht } = fn.fnMap();
    return h("body", {}, [
        h("div", {}, ht("View", "Hello, ")),
        h("div", {}, ht("View", "world!!")),
    ]);
};

export const getRootNode = () => {
    const root = renderApp();
    return JSON.stringify(root);
};

global.getRootNode = getRootNode;
