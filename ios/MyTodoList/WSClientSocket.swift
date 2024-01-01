//
//  WSClientSocket.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 12/31/23.
//

import Foundation
import Starscream

class WSClientSocket: NSObject, WebSocketDelegate {
    var request: URLRequest? = nil
    var socket: WebSocket? = nil

    func connectToBundler() {
        print("fetching...")
        request = URLRequest(url: URL(string: "ws://localhost:8080/websocket")!)
        request?.timeoutInterval = 5
        socket = WebSocket(request: request!)
        socket?.delegate = self

        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }

    func didReceive(event: Starscream.WebSocketEvent, client _: Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case let .disconnected(reason, code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case let .text(string):
            print("Received text: \(string)")
        case let .binary(data):
            print("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isConnected = false
        case let .error(error):
            isConnected = false
            print(error!)
        case .peerClosed:
            break
        }
    }
}
