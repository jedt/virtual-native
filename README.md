# virtual-native

Very WIP - Create macos native apps using Typescript. Construct a virtual DOM in typescript and see it render it in macos as NSViews. I would like to hear your thoughts, submit an issue

![screenshot](https://github.com/jedt/virtual-native/blob/main/screenshot.png?raw=true)

This is a small project to deconstruct the react native infrastructure.

Example code:

```
"use strict";
import * as fn from "./functions";

const renderApp = () => {
    const { h, ht } = fn.fnMap();
    return h("bodyOfTwo", {}, [
        h("divTargetLeft", {}, ht("View", "TargetLeft")),
        h(
            "divTarget",
            {},
            h("View", {}, [
                ht("View", "Sibling two"),
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
