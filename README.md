# Adobe MCP - Unified MCP Server for Adobe Creative Suite

Adobe MCP provides AI-powered automation for Adobe Creative Suite applications (Photoshop, Premiere Pro, Illustrator, and InDesign) through the Model Context Protocol (MCP). This enables AI assistants like Claude to control Adobe applications programmatically using natural language.

## Features

- **Multi-Application Support**: Control Photoshop, Premiere Pro, Illustrator, and InDesign
- **Natural Language Interface**: Use conversational commands to automate Adobe apps
- **Comprehensive API**: Access to layers, filters, text, selections, and more
- **Real-time Communication**: WebSocket-based proxy for instant command execution
- **Cross-Platform**: Works on Windows and macOS

## Architecture

The system uses a 3-tier architecture:

1. **MCP Servers** (Python) - Expose tools to AI/LLM clients
2. **Proxy Server** (Node.js) - WebSocket bridge between MCP and Adobe apps
3. **UXP Plugins** (JavaScript) - Execute commands within Adobe applications

## Installation

### Prerequisites

- Python 3.10+
- Node.js 18+
- Adobe Creative Suite applications (26.0+ for Photoshop, 25.3+ for Premiere)
- Adobe UXP Developer Tools

### Quick Install

1. Clone the repository:

```bash
git clone https://github.com/yourusername/adobe-mcp.git
cd adobe-mcp
```

2. Install Python dependencies:

```bash
pip install -e .
```

3. Install proxy server dependencies:

```bash
cd proxy-server
npm install
cd ..
```

4. Start the proxy server:

```bash
adobe-proxy
```

5. Install UXP plugins via Adobe UXP Developer Tools

## Usage

### Starting Individual MCP Servers

```bash
# Photoshop
adobe-photoshop

# Premiere Pro
adobe-premiere

# Illustrator (includes built-in proxy)
adobe-illustrator

# InDesign
adobe-indesign
```

### Claude Desktop Configuration

Add to your Claude desktop configuration:

```json
{
  "mcpServers": {
    "adobe-photoshop": {
      "command": "adobe-photoshop"
    },
    "adobe-premiere": {
      "command": "adobe-premiere"
    },
    "adobe-illustrator": {
      "command": "adobe-illustrator"
    },
    "adobe-indesign": {
      "command": "adobe-indesign"
    }
  }
}
```

### Example Prompts

- "Create a new Photoshop document with a blue gradient background"
- "Add a text layer saying 'Hello World' in 48pt Helvetica"
- "Apply a gaussian blur filter to the current layer"
- "Create a double exposure effect with two images"
- "Add cross-fade transitions between all clips in Premiere"

## UXP Plugin Installation

1. Launch Adobe UXP Developer Tools
2. Click "Add Plugin" and navigate to the appropriate plugin folder:
   - `uxp-plugins/photoshop` for Photoshop
   - `uxp-plugins/premiere` for Premiere Pro
   - `uxp-plugins/illustrator` for Illustrator
   - `uxp-plugins/indesign` for InDesign
3. Select the `manifest.json` file
4. Click "Load" to activate the plugin

## Development

### Project Structure

```
adobe-mcp/
├── adobe_mcp/           # Python MCP servers
│   ├── photoshop/      # Photoshop MCP server
│   ├── premiere/       # Premiere Pro MCP server
│   ├── illustrator/    # Illustrator MCP server
│   ├── indesign/       # InDesign MCP server
│   └── shared/         # Shared utilities
├── uxp-plugins/        # Adobe UXP plugins
│   ├── photoshop/      # Photoshop plugin
│   ├── premiere/       # Premiere plugin
│   ├── illustrator/    # Illustrator plugin
│   └── indesign/       # InDesign plugin
├── proxy-server/       # WebSocket proxy server
└── docs/              # Documentation
```

### Adding New Features

1. Add the API method to the appropriate MCP server
2. Implement the corresponding handler in the UXP plugin
3. Test the integration through the proxy server

## Troubleshooting

- **Plugin won't connect**: Ensure the proxy server is running on port 3001
- **Commands fail**: Check that the UXP plugin is loaded and connected
- **MCP server errors**: Verify Python dependencies are installed

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please read CONTRIBUTING.md for guidelines.

## Acknowledgments

This project integrates work from multiple Adobe automation projects and contributors.
