import websocket
import threading
import sys
import time  
import readline
import os

HISTORY_FILE = os.path.expanduser("~/.repl_history")
if os.path.exists(HISTORY_FILE):
    readline.read_history_file(HISTORY_FILE)

message_received_condition = threading.Condition()


def on_message(ws, message):
    with message_received_condition: 
        print("\r" + message) 
        print("\r")
        message_received_condition.notify()  


def on_error(ws, error):
    print("Error:", error)


def on_close(ws, close_status_code, close_msg):
    print("### Closed ###")


def send_loop(ws):
    while True:
        with message_received_condition:
            message_received_condition.wait()

            try:
                message = input("user> ")
                readline.write_history_file(HISTORY_FILE)
                if message == "exit":
                    print("\nDisconnecting...")
                    break
                ws.send(message)
            except ValueError as e:
                print("error:", e)
            except (KeyboardInterrupt, EOFError):
                break

    ws.close()


def on_open(ws):
    threading.Thread(target=send_loop, args=(ws,)).start()


def start_websocket():
    ws = websocket.WebSocketApp(
        "ws://127.0.0.1:8889/websocket",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close,
    )
    return ws


if __name__ == "__main__":
    reconnect_delay = 5 

    while True:
        ws = start_websocket()
        ws.run_forever()
        print(
            f"Disconnected. Attempting to reconnect 127.0.0.1:8889 in {reconnect_delay} seconds..."
        )
        time.sleep(reconnect_delay)
