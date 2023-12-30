"use strict";
import global from "global";
import { fnMap } from "./core.js";

export const renderApp = () => {
  const { h, ht } = fnMap();
  return h("body", {}, [ht("View", "Hello, world.")]);
};

const getRootNode = () => {
  const root = renderApp();
  return JSON.stringify(root);
};

console.log(getRootNode());

global.getRootNode = getRootNode;
