# Adobe MCP Windows Setup Guide

This guide will help you set up and test the Adobe MCP server on Windows.

## Prerequisites

1. **Adobe Creative Cloud** - Ensure you have the following installed:
   - Adobe Photoshop 2024 or later
   - Adobe Illustrator 2024 or later
   - Adobe Premiere Pro 2024 or later (optional)
   - Adobe InDesign 2024 or later (optional)

2. **Development Tools**:
   - Python 3.10 or later
   - Node.js 18 or later
   - Adobe UXP Developer Tools (from Creative Cloud)

## Setup Steps

### 1. Clone and Navigate to Repository

```bash
cd adobe-mcp-unified
```

### 2. Install Dependencies

#### For PowerShell (Recommended):
```powershell
.\install.ps1
```

#### For Command Prompt:
```batch
install.bat
```

This will:
- Detect installed Adobe applications
- Create a `config.windows.json` with correct paths
- Set up the Python virtual environment
- Install all dependencies

### 3. Install UXP Plugins

For each Adobe application you want to control:

1. Launch **Adobe UXP Developer Tools**
2. Click **"Add Plugin"**
3. Navigate to the appropriate plugin folder:
   - `uxp-plugins/photoshop` for Photoshop
   - `uxp-plugins/illustrator` for Illustrator
   - `uxp-plugins/premiere` for Premiere Pro
   - `uxp-plugins/indesign` for InDesign
4. Select the `manifest.json` file
5. Click **"Load"**

### 4. Start Services

Run the launcher and start services in this order:

#### For PowerShell:
```powershell
.\launch.ps1
```

#### For Command Prompt:
```batch
launch-windows.bat
```

1. **Start Proxy Server** (option 5 in menu)
   - This opens in a new window
   - Should show "adb-mcp Command proxy server running on ws://localhost:3001"

2. **Start MCP Server** for your app (options 1-4)
   - Choose the Adobe app you want to control
   - Should show the MCP server running

3. **Connect UXP Plugin**:
   - Open the Adobe application
   - Go to Plugins menu → Find your MCP Agent
   - Click "Connect" in the plugin panel
   - Status should change to "Connected"

## Testing the Integration

### Quick Test

1. Ensure all services are running (proxy + MCP + Adobe app)
2. Run the test suite:

#### PowerShell:
```powershell
.\run-tests.ps1
```

#### Command Prompt:
```batch
run-tests.bat
```

### Manual Test with Illustrator

1. Start all services as described above
2. Run manual test:

#### PowerShell:
```powershell
.\run-tests.ps1 manual
```

#### Command Prompt:
```batch
run-tests.bat manual
```

This will:
- Create a new Illustrator document
- Generate a logo design
- Create a vector illustration
- Save files to `%USERPROFILE%\Documents\Adobe_MCP_Tests\`

## Using with Claude Desktop

Add to your Claude Desktop configuration (`%APPDATA%\Claude\claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "adobe-photoshop": {
      "command": "C:\\path\\to\\adobe-mcp\\launch-windows.bat",
      "args": ["photoshop"]
    },
    "adobe-illustrator": {
      "command": "C:\\path\\to\\adobe-mcp\\launch-windows.bat",
      "args": ["illustrator"]
    }
  }
}
```

## Troubleshooting

### Adobe App Not Found
- Run `python -m adobe_mcp.shared.adobe_detector` to check detection
- Manually edit `config.windows.json` with correct paths

### Plugin Won't Connect
- Ensure proxy server is running (check http://localhost:3001/status)
- Reload plugin in UXP Developer Tools
- Check Windows Firewall isn't blocking ports

### MCP Server Errors
- Check Python virtual environment is activated
- Verify all dependencies installed: `pip list`
- Check `config.windows.json` has correct paths

### Test Failures
- Ensure Illustrator is running before tests
- Check `%USERPROFILE%\Documents\Adobe_MCP_Tests\` directory is writable
- Verify UXP plugin shows "Connected"

## Example Commands

Once everything is set up, you can:

### Via Python Script
```python
from tests.test_illustrator import IllustratorTester
import asyncio

async def create_design():
    tester = IllustratorTester()
    await tester.create_test_document()
    await tester.create_logo_design()
    
    import os
    save_path = os.path.join(os.environ['USERPROFILE'], 'Documents', 'Adobe_MCP_Tests', 'my_logo.ai')
    await tester.save_document(save_path.replace('\\', '/'))
    await tester.close()

asyncio.run(create_design())
```

### Via MCP Protocol
Send commands like:
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "execute_script",
    "arguments": {
      "script": "app.documents.add();"
    }
  },
  "id": 1
}
```

## Next Steps

- Explore the test scripts in `tests/` for more examples
- Check individual app documentation in each server module
- Create your own automation scripts
- Integrate with your AI workflows