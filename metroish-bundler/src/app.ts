"use strict";
import * as fn from "./functions";

export const renderApp = () => {
    const { h, ht } = fn.fnMap();
    return h("body", {}, [ht("View", "Hello, world.")]);
};

const getRootNode = () => {
    const root = renderApp();
    return JSON.stringify(root);
};

console.log(getRootNode());
