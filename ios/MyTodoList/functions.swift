//
//  functions.swift
//  MyTodoList
//
//  Created by Jed Tiotuico on 12/31/23.
//

import Foundation
import JavaScriptCore
import Swifter
import Dispatch
import Starscream

let context = JSContext()

var isConnected = false

let socketDelegate = WSClientSocket()

func evalJS(_ receivedString: String) -> String {
    let output_value : JSValue = (context?.evaluateScript(receivedString))!
    print(output_value);
    return output_value.toString() ?? "Error"
}

let server = HttpServer()

func READ(_ str: String) -> String{
    return str
}
let localPath = "/Users/jedtiotuico/swift/vdom-native/ios/MyTodoList/main.bundle.js"
let urlString = "http://127.0.0.1:8080/download"
func EVAL(_ str: String) -> String {
    let semaphore = DispatchSemaphore(value: 0)
    var resultString = ""
    do {
        switch (str) {
        case "fetch":
            socketDelegate.connectToBundler();
            break
        case "download":
                let fileURL = URL(string: urlString)!
                let destinationURL = URL(fileURLWithPath: localPath)
                downloadFile(from: urlString, to: localPath) { fileContents, error in
                    if let error = error {
                        print("Download failed: \(error)")
                        semaphore.signal()
                    } else if let fileContents = fileContents {
                        let context = JSContext()
                        context?.evaluateScript(fileContents)

                        if let rootNodeFunction = context?.objectForKeyedSubscript("getRootNode"), let result = rootNodeFunction.call(withArguments: []) {
                            if let output = result.toString() {
                                //this will return and return EVAL
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
            break
        case "disconnect":
                break
        default:
                break
        }
    } catch {
        print("Error reading file: \(error)")
    }
    return str
}

func PRINT(_ exp: String) -> String {
    return exp
}

func rep(str: String) -> String {
    return PRINT(EVAL(READ(str)));
}

func connectToBundler() {
    socketDelegate.connectToBundler();
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

func downloadFile(from urlString: String, to localPath: String, completion: @escaping (String?, Error?) -> ()) {
    guard let url = URL(string: urlString) else {
        completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        return
    }

    let task = URLSession.shared.downloadTask(with: url) { tempLocalUrl, response, error in
        if let tempLocalUrl = tempLocalUrl, error == nil {
            // Define 'destinationUrl' here
            let destinationUrl = URL(fileURLWithPath: localPath)
            
            do {
                // Remove existing file at destination if it exists
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }

                // Move the downloaded file to the destination
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
        server["/"] = { .ok(.htmlBody("You asked for \($0)"))  }
        
        server["/websocket"] = websocket(
            text: { session, text in
                session.writeText(rep(str: text))
            },
            connected: { session in
                session.writeText("you are connected")
            })
        
        try server.start(8889, forceIPv4: true)
        print("started listening on 8889")
    }
    catch {
        print("server error")
    }
}
