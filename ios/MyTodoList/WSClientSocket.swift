//
//  WSClientSocket.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 12/31/23.
//

import Foundation
import Starscream

class WSClientSocket : NSObject, WebSocketDelegate {
    var request : URLRequest? = nil
    var socket : WebSocket? = nil
    
    func connectToBundler() {
        print("fetching...")
        self.request = URLRequest(url: URL(string: "ws://localhost:8080/websocket")!)
        self.request?.timeoutInterval = 5
        self.socket = WebSocket(request: self.request!)
        self.socket?.delegate = self
        self.socket?.connect()
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            print(error!)
            case .peerClosed:
                   break
        }
    }
}
