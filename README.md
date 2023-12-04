# virtual-native
Create native apps in macOS using Javascript virtual DOM

This is a small project to deconstruct the react native infrastructure. Removing react from react-native and only using a virtual dom

Example code:
```
import h from 'virtual-dom/h';

function render()  {
    let body = h('body', null, [
        h('div', { id: 'foo' }, 'Hello!'),
        h('div', { id: 'bar' }, 'World!')
    ])

    return h('div', { id: 'root' }, body);
}

let root = render();

//global.getAllFunctions
global.getRootNode = function() {
    return JSON.stringify(root);
}
```

## Requirements:
* XCode
* node

## Instructions
* Fork this repo
* run npm install on the `metroish-bundler` folder
* then npm start
* run pod install on the `ios` folder
* open ios/MyTodoList.xcworkspace and build

