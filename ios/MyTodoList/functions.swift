//
//  functions.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 12/31/23.
//

import Dispatch
import Foundation
import JavaScriptCore
import Starscream
import Swifter

let context = JSContext()

var isConnected = false
let socketDelegate = WSClientSocket()
let server = HttpServer()
let localPath = "/Users/jedtiotuico/swift/vdom-native/ios/MyTodoList/main.bundle.js"
let urlString = "http://127.0.0.1:8080/download"

func evalJS(_ receivedString: String) -> String {
    let output_value: JSValue = (context?.evaluateScript(receivedString))!
    return output_value.toString() ?? "Error"
}

func READ(_ str: String) -> String {
    return str
}

func EVAL(_ str: String) -> String {
    let semaphore = DispatchSemaphore(value: 0)
    var resultString = ""
    switch str {
        case "fetch":
            socketDelegate.connectToBundler()
        case "download":
            let fileURL = URL(string: urlString)!
            let destinationURL = URL(fileURLWithPath: localPath)
            downloadFile(from: urlString, to: localPath) { fileContents, error in
                if let error {
                    print("Download failed: \(error)")
                    semaphore.signal()
                } else if let fileContents {
                    let context = JSContext()
                    context?.evaluateScript(fileContents)

                    if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                        if let output = result.toString() {
                            // this will return and return EVAL
                            resultString = output
                            semaphore.signal()
                        }
                    }
                } else {
                    semaphore.signal()
                    print("Downloaded file is empty or could not be read.")
                }
            }
            semaphore.wait()
            return resultString
        case "disconnect":
            break
        default:
            break
    }
    return str
}

func PRINT(_ exp: String) -> String {
    return exp
}

func rep(str: String) -> String {
    PRINT(EVAL(READ(str)))
}

func connectToBundler() {
    socketDelegate.connectToBundler()
}

func readFileToString(from filePath: String) -> String? {
    do {
        let contents = try String(contentsOfFile: filePath)
        return contents
    } catch {
        print("Error reading file: \(error)")
        return nil
    }
}

func downloadFile(from urlString: String, to localPath: String, completion: @escaping (String?, Error?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, _, error in
        if let tempLocalUrl, error == nil {
            let destinationUrl = URL(fileURLWithPath: localPath)

            do {
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }

                try FileManager.default.moveItem(at: tempLocalUrl, to: destinationUrl)
                if let fileContents = readFileToString(from: localPath) {
                    completion(fileContents, nil)
                } else {
                    print("Failed to read the file.")
                }
                completion(nil, error)
            } catch {
                completion(nil, error)
            }
        } else {
            completion(nil, error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
    }

    task.resume()
}

func startServer() {
    do {
        server.listenAddressIPv4 = "127.0.0.1"
        server["/"] = { .ok(.htmlBody("You asked for \($0)")) }

        server["/websocket"] = websocket(
            text: { session, text in
                session.writeText(rep(str: text))
            },
            connected: { session in
                session.writeText("you are connected")
            })

        try server.start(8889, forceIPv4: true)
        print("started listening on 8889")
    } catch {
        print("server error")
    }
}
