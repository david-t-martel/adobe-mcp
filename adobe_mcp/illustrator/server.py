import asyncio
import http.server
import json
import socketserver
import threading
from http import HTTPStatus

import httpx
import uvicorn
from fastmcp import FastMCP

# --- Part 1: Command Proxy Server Logic ---
# This part of the code runs a simple, synchronous HTTP server in its own thread
# to act as a message box for the UXP plugin.


class CommandStore:
    """A thread-safe class to store the latest command."""

    def __init__(self):
        self.script = None
        self.lock = threading.Lock()

    def set_script(self, script):
        with self.lock:
            self.script = script

    def get_and_clear_script(self):
        with self.lock:
            script = self.script
            self.script = None
            return script


command_store = CommandStore()


class ProxyHandler(http.server.SimpleHTTPRequestHandler):
    """Handles GET requests from the UXP plugin and POST requests from the MCP server."""

    def do_POST(self):
        if self.path == "/command":
            try:
                content_length = int(self.headers["Content-Length"])
                data = json.loads(self.rfile.read(content_length))
                command_store.set_script(data.get("script"))
                self._send_response(HTTPStatus.OK, {"status": "command received"})
            except Exception as e:
                self._send_response(HTTPStatus.INTERNAL_SERVER_ERROR, {"error": str(e)})
        else:
            self._send_response(HTTPStatus.NOT_FOUND, {"error": "Not Found"})

    def do_GET(self):
        if self.path == "/command":
            script = command_store.get_and_clear_script()
            self._send_response(HTTPStatus.OK, {"script": script})
        else:
            self._send_response(HTTPStatus.NOT_FOUND, {"error": "Not Found"})

    def _send_response(self, status, content):
        self.send_response(status)
        self.send_header("Content-type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(content).encode("utf-8"))


# --- Part 2: Main MCP Server Logic (fastmcp) ---
# This part of the code defines the high-performance async server that
# the LLM agent communicates with.

PROXY_POST_URL = "http://127.0.0.1:8001/command"

mcp = FastMCP(
    "illustrator_pro",
    description="A professional tool to control Adobe Illustrator via a UXP plugin.",
)


@mcp.tool()
async def execute_script(script: str) -> str:
    """Sends a JavaScript string to be executed inside Adobe Illustrator."""
    async with httpx.AsyncClient() as client:
        try:
            await client.post(PROXY_POST_URL, json={"script": script})
            return "Success: Command forwarded to Illustrator."
        except httpx.RequestError as e:
            return f"Error: Cannot connect to proxy server. Is it running? Details: {e}"


# --- Part 3: Unified Server Runner ---
# This part uses asyncio to run both the synchronous proxy server and the
# asynchronous fastmcp server within the same process.


async def main():
    """Starts both the proxy and MCP servers concurrently."""
    loop = asyncio.get_event_loop()

    # Configure and run the synchronous proxy server in a separate thread
    proxy_server = socketserver.TCPServer(("", 8001), ProxyHandler)
    proxy_thread = threading.Thread(target=proxy_server.serve_forever)
    proxy_thread.daemon = True
    proxy_thread.start()
    print("Proxy Server started on port 8001 in a background thread.")

    # Configure and run the asynchronous fastmcp/uvicorn server
    config = uvicorn.Config(mcp.app, host="127.0.0.1", port=8000, log_level="info")
    server = uvicorn.Server(config)
    print("Main MCP Server starting on port 8000.")

    # Uvicorn's serve() is awaitable and will run in the main asyncio loop
    await server.serve()

    # This part will only be reached if the server is stopped
    print("Shutting down servers...")
    proxy_server.shutdown()


def run_server():
    """Run the Illustrator MCP server with integrated proxy."""
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nServers stopped by user.")

if __name__ == "__main__":
    run_server()
