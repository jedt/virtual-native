'use strict';
import global from 'global';
import h from 'virtual-dom/h';
import toJson from './to-json';

function render()  {
    let grandChildren = [
        h('div', { id: '12345', backgroundColor: '#FFB6C1' }),
        h('div', { id: 'second-grandchild', backgroundColor: '#B0C4DE' }),
    ];

    let children = [
        h('div', { id: 'first-child', flexDirection: 'row', backgroundColor: '#FFB6C1' }, grandChildren),
        h('div', { id: 'second-child', backgroundColor: '#B0C4DE' }),
        h('div', { id: 'third-child', backgroundColor: '#FFDEAD' }),
    ];

    let body = h('body', null, [
        h('div', {
            id: 'body-div',
            backgroundColor: '#4F94CD',
            flexDirection: 'column',
        }, children),
    ])

    return h('div', { id: 'root', backgroundColor: '#FFFFFF' }, body);
}

let root = render();

//global.getAllFunctions
global.getRootNode = function() {
    return JSON.stringify(toJson(root));
}
