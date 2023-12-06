(()=>{var t={715:t=>{t.exports=function(t){var e,r=String.prototype.split,n=/()??/.exec("")[1]===t;return e=function(e,o,i){if("[object RegExp]"!==Object.prototype.toString.call(o))return r.call(e,o,i);var a,s,u,c,p=[],l=(o.ignoreCase?"i":"")+(o.multiline?"m":"")+(o.extended?"x":"")+(o.sticky?"y":""),h=0;o=new RegExp(o.source,l+"g");for(e+="",n||(a=new RegExp("^"+o.source+"$(?!\\s)",l)),i=i===t?-1>>>0:i>>>0;(s=o.exec(e))&&!((u=s.index+s[0].length)>h&&(p.push(e.slice(h,s.index)),!n&&s.length>1&&s[0].replace(a,(function(){for(var e=1;e<arguments.length-2;e++)arguments[e]===t&&(s[e]=t)})),s.length>1&&s.index<e.length&&Array.prototype.push.apply(p,s.slice(1)),c=s[0].length,h=u,p.length>=i));)o.lastIndex===s.index&&o.lastIndex++;return h===e.length?!c&&o.test("")||p.push(""):p.push(e.slice(h)),p.length>i?p.slice(0,i):p},e}()},738:(t,e,r)=>{"use strict";r(147)("ev-store","7");var n="__EV_STORE_KEY@7";t.exports=function(t){var e=t[n];e||(e=t[n]={});return e}},948:(t,e,r)=>{var n;n="undefined"!=typeof window?window:void 0!==r.g?r.g:"undefined"!=typeof self?self:{},t.exports=n},145:(t,e,r)=>{"use strict";var n="undefined"!=typeof window?window:void 0!==r.g?r.g:{};t.exports=function(t,e){if(t in n)return n[t];return n[t]=e,e}},147:(t,e,r)=>{"use strict";var n=r(145);t.exports=function(t,e,r){var o="__INDIVIDUAL_ONE_VERSION_"+t,i=n(o+"_ENFORCE_SINGLETON",e);if(i!==e)throw new Error("Can only have one copy of "+t+".\nYou already have version "+i+" installed.\nThis means you cannot install version "+e);return n(o,r)}},114:t=>{"use strict";t.exports=function(t){var e,r={};if(!(t instanceof Object)||Array.isArray(t))throw new Error("keyMirror(...): Argument must be an object.");for(e in t)t.hasOwnProperty(e)&&(r[e]=e);return r}},405:(t,e,r)=>{var n=r(939);t.exports=n},367:(t,e,r)=>{"use strict";var n=r(738);function o(t){if(!(this instanceof o))return new o(t);this.value=t}t.exports=o,o.prototype.hook=function(t,e){n(t)[e.substr(3)]=this.value},o.prototype.unhook=function(t,e){n(t)[e.substr(3)]=void 0}},426:t=>{"use strict";function e(t){if(!(this instanceof e))return new e(t);this.value=t}t.exports=e,e.prototype.hook=function(t,e){t[e]!==this.value&&(t[e]=this.value)}},939:(t,e,r)=>{"use strict";var n=r(217),o=r(7),i=r(536),a=r(68),s=r(876),u=r(485),c=r(289),p=r(951),l=r(943),h=r(426),f=r(367);function d(t,e,r,o){if("string"==typeof t)e.push(new i(t));else if("number"==typeof t)e.push(new i(String(t)));else if(v(t))e.push(t);else{if(!n(t)){if(null==t)return;throw s={foreignObject:t,parentVnode:{tagName:r,properties:o}},(u=new Error).type="virtual-hyperscript.unexpected.virtual-element",u.message="Unexpected virtual child passed to h().\nExpected a VNode / Vthunk / VWidget / string but:\ngot:\n"+y(s.foreignObject)+".\nThe parent vnode is:\n"+y(s.parentVnode),u.foreignObject=s.foreignObject,u.parentVnode=s.parentVnode,u}for(var a=0;a<t.length;a++)d(t[a],e,r,o)}var s,u}function v(t){return a(t)||s(t)||u(t)||p(t)}function y(t){try{return JSON.stringify(t,null,"    ")}catch(e){return String(t)}}t.exports=function(t,e,r){var i,a,s,u,p=[];!r&&(y=e,"string"==typeof y||n(y)||v(y))&&(r=e,a={});var y;i=l(t,a=a||e||{}),a.hasOwnProperty("key")&&(s=a.key,a.key=void 0);a.hasOwnProperty("namespace")&&(u=a.namespace,a.namespace=void 0);"INPUT"!==i||u||!a.hasOwnProperty("value")||void 0===a.value||c(a.value)||(a.value=h(a.value));(function(t){for(var e in t)if(t.hasOwnProperty(e)){var r=t[e];if(c(r))continue;"ev-"===e.substr(0,3)&&(t[e]=f(r))}})(a),null!=r&&d(r,p,i,a);return new o(i,a,p,s,u)}},943:(t,e,r)=>{"use strict";var n=r(715),o=/([\.#]?[a-zA-Z0-9\u007F-\uFFFF_:-]+)/,i=/^\.|#/;t.exports=function(t,e){if(!t)return"DIV";var r,a,s,u,c=!e.hasOwnProperty("id"),p=n(t,o),l=null;i.test(p[1])&&(l="DIV");for(u=0;u<p.length;u++)(a=p[u])&&(s=a.charAt(0),l?"."===s?(r=r||[]).push(a.substring(1,a.length)):"#"===s&&c&&(e.id=a.substring(1,a.length)):l=a);r&&(e.className&&r.push(e.className),e.className=r.join(" "));return e.namespace?l:l.toUpperCase()}},951:t=>{t.exports=function(t){return t&&"Thunk"===t.type}},289:t=>{t.exports=function(t){return t&&("function"==typeof t.hook&&!t.hasOwnProperty("hook")||"function"==typeof t.unhook&&!t.hasOwnProperty("unhook"))}},68:(t,e,r)=>{var n=r(550);t.exports=function(t){return t&&"VirtualNode"===t.type&&t.version===n}},876:(t,e,r)=>{var n=r(550);t.exports=function(t){return t&&"VirtualText"===t.type&&t.version===n}},485:t=>{t.exports=function(t){return t&&"Widget"===t.type}},550:t=>{t.exports="2"},7:(t,e,r)=>{var n=r(550),o=r(68),i=r(485),a=r(951),s=r(289);t.exports=p;var u={},c=[];function p(t,e,r,n,p){this.tagName=t,this.properties=e||u,this.children=r||c,this.key=null!=n?String(n):void 0,this.namespace="string"==typeof p?p:null;var l,h=r&&r.length||0,f=0,d=!1,v=!1,y=!1;for(var g in e)if(e.hasOwnProperty(g)){var x=e[g];s(x)&&x.unhook&&(l||(l={}),l[g]=x)}for(var w=0;w<h;w++){var b=r[w];o(b)?(f+=b.count||0,!d&&b.hasWidgets&&(d=!0),!v&&b.hasThunks&&(v=!0),y||!b.hooks&&!b.descendantHooks||(y=!0)):!d&&i(b)?"function"==typeof b.destroy&&(d=!0):!v&&a(b)&&(v=!0)}this.count=h+f,this.hasWidgets=d,this.hasThunks=v,this.hooks=l,this.descendantHooks=y}p.prototype.version=n,p.prototype.type="VirtualNode"},536:(t,e,r)=>{var n=r(550);function o(t){this.text=String(t)}t.exports=o,o.prototype.version=n,o.prototype.type="VirtualText"},217:t=>{var e=Array.isArray,r=Object.prototype.toString;t.exports=e||function(t){return"[object Array]"===r.call(t)}}},e={};function r(n){var o=e[n];if(void 0!==o)return o.exports;var i=e[n]={exports:{}};return t[n](i,i.exports,r),i.exports}r.n=t=>{var e=t&&t.__esModule?()=>t.default:()=>t;return r.d(e,{a:e}),e},r.d=(t,e)=>{for(var n in e)r.o(e,n)&&!r.o(t,n)&&Object.defineProperty(t,n,{enumerable:!0,get:e[n]})},r.g=function(){if("object"==typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(t){if("object"==typeof window)return window}}(),r.o=(t,e)=>Object.prototype.hasOwnProperty.call(t,e),(()=>{"use strict";var t=r(948),e=r.n(t),n=r(405),o=r.n(n),i=r(114);const a="____UnDeFiNeD____",s=r.n(i)()({VirtualTree:null,VirtualPatch:null,VirtualNode:null,SoftSetHook:null});function u(t,e){for(var r=t.length,n=-1,o=new Array(r);++n<r;)o[n]=l(t[n],e);return o}function c(t,e){var r,n,o={},i=!1,s=e;for(var u in t&&t.a&&t.a.tagName&&(r={},n=e,Object.keys(n).forEach((function(t){r[t]=n[t]})),s=r,i=!0),t){var c=t[u];i&&(s.patchHashIndex=parseInt(u)),o[u]=void 0!==c?l(c,s):a}return o}function p(t,e){return"patch"in t&&"number"==typeof t.type?function(t,e){var r={t:s.VirtualPatch,pt:t.type};return t.vNode&&(e&&null!=e.patchHashIndex?r.v="i:"+e.patchHashIndex:r.v=l(t.vNode,e)),t.patch&&(r.p=l(t.patch,e)),r}(t,e):"VirtualNode"===t.type?function(t,e){var r={t:s.VirtualNode,tn:t.tagName};return Object.keys(t.properties).length&&(r.p=c(t.properties,e)),t.children.length&&(r.c=u(t.children,e)),t.key&&(r.k=t.key),t.namespace&&(r.n=t.namespace),r}(t,e):"VirtualText"===t.type?function(t,e){return{t:s.VirtualTree,x:t.text}}(t):c(t,e)}function l(t,e){switch(typeof t){case"string":case"boolean":case"number":return t}return Array.isArray(t)?u(t,e||{}):t?(t&&t.a&&t.a.tagName&&!e?e={diffRoot:t.a}:null==e&&(e={}),p(t,e)):null}const h=l;let f=function(){const t=[o()("div",{id:"1234",backgroundColor:"#EAEAEA"}),o()("div",{id:"2222",backgroundColor:"#EAEAEA"})],e=o()("text",{text:"The the Lazy Dog",fontSize:12}),r=[o()("div",{id:"first-child",flexDirection:"row",backgroundColor:"#FFB6C1"},t),o()("div",{id:"mid-div",backgroundColor:"#EAEAEA"},e),o()("div",{id:"third-child",backgroundColor:"#EAEAEA"})],n=o()("body",null,[o()("div",{id:"body-div",backgroundColor:"#FAFAFA",flexDirection:"column"},r)]);return o()("div",{id:"root"},n)}();e().getRootNode=function(){return JSON.stringify(h(f))}})()})();