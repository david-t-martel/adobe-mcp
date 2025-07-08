"""Main entry point for Photoshop MCP server."""
import sys
from .server import mcp

if __name__ == "__main__":
    mcp.run(sys.stdin.buffer, sys.stdout.buffer)