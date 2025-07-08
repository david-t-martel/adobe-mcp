"""Adobe Illustrator MCP Server with integrated proxy."""

from .server import mcp, run_server

def main():
    """Entry point for Illustrator MCP server."""
    run_server()

__all__ = ["mcp", "main", "run_server"]