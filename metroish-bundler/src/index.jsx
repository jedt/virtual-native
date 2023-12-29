"use strict";
import { h, render, View, Component } from "preact";

class App extends Component {
	render() {
		return (
			<View>
				<h1>Hello, world!</h1>
			</View>
		);
	}
}

export const getRootNode = () => {
	const root = render(<App />);
	return JSON.stringify(root);
};

global.getRootNode = getRootNode;
