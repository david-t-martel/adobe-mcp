"""Adobe MCP Proxy Server launcher."""

import subprocess
import sys
import os

def main():
    """Launch the Node.js proxy server."""
    proxy_dir = os.path.join(os.path.dirname(__file__), "..", "proxy-server")
    
    # Check if node_modules exists
    node_modules = os.path.join(proxy_dir, "node_modules")
    if not os.path.exists(node_modules):
        print("Installing proxy server dependencies...")
        subprocess.run(["npm", "install"], cwd=proxy_dir, check=True)
    
    # Run the proxy server
    print("Starting Adobe MCP Proxy Server...")
    try:
        subprocess.run(["node", "proxy.js"], cwd=proxy_dir, check=True)
    except KeyboardInterrupt:
        print("\nProxy server stopped by user.")
        sys.exit(0)

if __name__ == "__main__":
    main()