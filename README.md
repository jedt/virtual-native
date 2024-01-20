# virtual-native

Very WIP - Create macos native apps using Typescript. Construct a virtual DOM in typescript and see it render it in macos as NSViews. I would like to hear your thoughts, submit an issue

![screenshot](https://github.com/jedt/virtual-native/blob/main/screenshot.png?raw=true)

This is a small project to deconstruct the react native infrastructure.

Example code:

```
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
```

## Requirements:

- XCode
- node

## Instructions

- Fork this repo
- run npm install on the `metroish-bundler` folder
- then npm start
- run pod install on the `ios` folder
- open ios/MyTodoList.xcworkspace and build

## Run the metroish-bundler

- cd metroish-bundler
- npm start

## Run the macos app

- open MyTodoList.xcworkspace in XCode
- Build and Run
- it should listen for changes via websockets from the metroish-bundler (webpack)
- try changing src/app.ts and see the results

## Access the repl (optional)

- cd tools-cli
- python client.py
- user> start
- user> download
