'use strict';
import global from 'global';
import h from 'virtual-dom/h';
import h2 from 'hyperscript-helpers';
import md5 from 'crypto-js/md5';

const { div, plaintext } = h2(h);
import toJson from './to-json';

const styles = {
  main: {
    backgroundColor: '#48D1CC',
  },
  container: {
      backgroundColor: '#EAEAEA',
  },
  row1: {
    flexDirection: 'row',
    backgroundColor: 'rgba(255,229,182,0.75)',
  },
  row2: {
    backgroundColor: '#FFB611',
  },
  row3: {
    backgroundColor: '#FFB666',
  },
  rowWithCol: {
      flexDirection: 'row',
      backgroundColor: '#8babb4'
  },
  col1: {
    backgroundColor: '#d8debb',
  },
  col2: {
    backgroundColor: '#6a7679',
  }
};

export const addIDsToNode = (node) => {
  (function traverseNodeAndAddIDs(node) {
      // Generate a unique ID for this node
      if (node) {
        if (Object.hasOwnProperty.call(node, 'properties')) {
          const objectString = JSON.stringify(node);
          node.properties.id = md5(objectString).toString();

        } else {
          node.properties = {};
        }
      }

      if (node.children && node.children.length) {
          node.children.forEach(child => {
              traverseNodeAndAddIDs(child);
          });
      }
  })(node);

  return [node, toJson];
}
export const beforeRender = (node) => {
    const [nodeWithIDs] = addIDsToNode(node);
    return nodeWithIDs;
}

export const renderApp = () => {
    return beforeRender(
      div('.root', styles.main,
        div(styles.container, [
          div(styles.rowWithCol, [
            div(styles.col1, [
              plaintext({text:'Number :', fontSize: 12}),
            ]),
            div(styles.col1, [
              plaintext({text:'Value: ', fontSize: 12}),
            ]),
          ]),
        ]),
      )
    );
}

export const getRootNode = () => {
    const root = renderApp();
    return JSON.stringify(toJson(root));
}

global.getRootNode = getRootNode
