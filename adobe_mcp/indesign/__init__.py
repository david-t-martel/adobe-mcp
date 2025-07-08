"""Adobe InDesign MCP Server."""

from .server import mcp

def main():
    """Entry point for InDesign MCP server."""
    import sys
    mcp.run(sys.stdin.buffer, sys.stdout.buffer)

__all__ = ["mcp", "main"]