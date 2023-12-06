'use strict';
import global from 'global';
import h from 'virtual-dom/h';
import toJson from './to-json';

function render()  {
    const grandChildren = [
        h('div', { id: '1234', backgroundColor: '#EAEAEA' }),
        h('div', { id: '2222', backgroundColor: '#EAEAEA' }),
    ];

    const mid = h('text', {text:'Lazy Dog 123', fontSize: 12});

    const children = [
        h('div', { id: 'first-child', flexDirection: 'row', backgroundColor: '#FFB6C1' }, grandChildren),
        h('div', { id: 'mid-div', backgroundColor: '#EAEAEA'}, mid),
        h('div', { id: 'third-child', backgroundColor: '#EAEAEA' }),
    ];

    const body = h('body', null, [
        h('div', {
            id: 'body-div',
            backgroundColor: '#FAFAFA',
            flexDirection: 'column',
        }, children),
    ])

    return h('div', { id: 'root'}, body);
}

let root = render();

//global.getAllFunctions
global.getRootNode = function() {
    return JSON.stringify(toJson(root));
}
