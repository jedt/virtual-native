import h from 'virtual-dom/h';

function render()  {
    let body = h('body', null, [
        h('div', { id: 'hello-id' }, 'Hello!'),
        h('div', { id: 'world-id' }, 'World!')
    ])

    return h('div', { id: 'root' }, body);
}

let root = render();

//global.getAllFunctions
global.getRootNode = function() {
    return JSON.stringify(root);
}
