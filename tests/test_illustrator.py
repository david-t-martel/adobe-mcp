"""Test Illustrator MCP integration and graphics generation."""
import asyncio
import json
import time
from pathlib import Path
import httpx
import pytest

# Test configuration
PROXY_URL = "http://localhost:3001"
MCP_URL = "http://localhost:8000"
TEST_TIMEOUT = 30

class IllustratorTester:
    """Test harness for Illustrator MCP integration."""
    
    def __init__(self):
        self.client = httpx.AsyncClient(timeout=TEST_TIMEOUT)
        
    async def check_proxy_status(self):
        """Check if proxy server is running."""
        try:
            response = await self.client.get(f"{PROXY_URL}/status")
            return response.status_code == 200
        except:
            return False
            
    async def check_mcp_status(self):
        """Check if MCP server is running."""
        try:
            response = await self.client.get(f"{MCP_URL}/health")
            return response.status_code == 200
        except:
            return False
            
    async def execute_script(self, script):
        """Execute JavaScript in Illustrator via MCP."""
        payload = {
            "jsonrpc": "2.0",
            "method": "tools/call",
            "params": {
                "name": "execute_script",
                "arguments": {
                    "script": script
                }
            },
            "id": 1
        }
        
        response = await self.client.post(
            f"{MCP_URL}/",
            json=payload
        )
        
        result = response.json()
        if "error" in result:
            raise Exception(f"MCP Error: {result['error']}")
            
        return result.get("result")

    async def create_test_document(self):
        """Create a new Illustrator document for testing."""
        script = """
        // Create new document
        var doc = app.documents.add(
            DocumentColorSpace.RGB,
            800,  // width
            600,  // height
            1,    // artboards
            DocumentArtboardLayout.GridByRow,
            72.0, // spacing
            3     // columns
        );
        doc.name = "Test Document";
        doc.artboards[0].name = "Test Artboard";
        "Document created: " + doc.name;
        """
        return await self.execute_script(script)
        
    async def create_logo_design(self):
        """Create a sample logo design."""
        script = """
        var doc = app.activeDocument;
        
        // Create background circle
        var bgCircle = doc.pathItems.ellipse(400, 200, 400, 400);
        var bgColor = new RGBColor();
        bgColor.red = 41;
        bgColor.green = 128;
        bgColor.blue = 185;
        bgCircle.filled = true;
        bgCircle.fillColor = bgColor;
        bgCircle.stroked = false;
        
        // Create inner circle
        var innerCircle = doc.pathItems.ellipse(350, 250, 300, 300);
        var innerColor = new RGBColor();
        innerColor.red = 255;
        innerColor.green = 255;
        innerColor.blue = 255;
        innerCircle.filled = true;
        innerCircle.fillColor = innerColor;
        innerCircle.stroked = false;
        
        // Create text
        var textFrame = doc.textFrames.add();
        textFrame.contents = "ADOBE\\nMCP";
        textFrame.position = [300, 450];
        
        // Style the text
        var textStyle = textFrame.textRange;
        textStyle.characterAttributes.size = 48;
        textStyle.characterAttributes.fillColor = bgColor;
        textStyle.justification = Justification.CENTER;
        
        // Create star accent
        var star = doc.pathItems.star(500, 300, 50, 25, 5);
        var starColor = new RGBColor();
        starColor.red = 241;
        starColor.green = 196;
        starColor.blue = 15;
        star.filled = true;
        star.fillColor = starColor;
        star.stroked = false;
        
        "Logo design created";
        """
        return await self.execute_script(script)
        
    async def create_vector_illustration(self):
        """Create a vector illustration with gradients."""
        script = """
        var doc = app.activeDocument;
        
        // Create gradient
        var gradient = doc.gradients.add();
        gradient.name = "Sky Gradient";
        gradient.type = GradientType.LINEAR;
        
        var color1 = new RGBColor();
        color1.red = 135;
        color1.green = 206;
        color1.blue = 235;
        
        var color2 = new RGBColor();
        color2.red = 255;
        color2.green = 255;
        color2.blue = 255;
        
        gradient.gradientStops[0].color = color1;
        gradient.gradientStops[1].color = color2;
        
        // Create sky background
        var sky = doc.pathItems.rectangle(600, 0, 800, 400);
        var skyGradient = new GradientColor();
        skyGradient.gradient = gradient;
        skyGradient.angle = -90;
        sky.filled = true;
        sky.fillColor = skyGradient;
        sky.stroked = false;
        
        // Create sun
        var sun = doc.pathItems.ellipse(500, 50, 100, 100);
        var sunColor = new RGBColor();
        sunColor.red = 255;
        sunColor.green = 223;
        sunColor.blue = 0;
        sun.filled = true;
        sun.fillColor = sunColor;
        sun.stroked = false;
        
        // Create clouds
        for (var i = 0; i < 3; i++) {
            var cloudGroup = doc.groupItems.add();
            
            var cloud1 = doc.pathItems.ellipse(
                400 - i * 50, 
                150 + i * 100, 
                80, 80
            );
            cloud1.moveToBeginning(cloudGroup);
            
            var cloud2 = doc.pathItems.ellipse(
                380 - i * 50, 
                180 + i * 100, 
                60, 60
            );
            cloud2.moveToBeginning(cloudGroup);
            
            var cloud3 = doc.pathItems.ellipse(
                360 - i * 50, 
                200 + i * 100, 
                70, 70
            );
            cloud3.moveToBeginning(cloudGroup);
            
            // Apply white color to all cloud parts
            var cloudColor = new RGBColor();
            cloudColor.red = 255;
            cloudColor.green = 255;
            cloudColor.blue = 255;
            
            for (var j = 0; j < cloudGroup.pathItems.length; j++) {
                cloudGroup.pathItems[j].filled = true;
                cloudGroup.pathItems[j].fillColor = cloudColor;
                cloudGroup.pathItems[j].stroked = false;
            }
        }
        
        "Vector illustration created";
        """
        return await self.execute_script(script)
        
    async def save_document(self, filename):
        """Save the current document."""
        script = f"""
        var doc = app.activeDocument;
        var saveOptions = new IllustratorSaveOptions();
        saveOptions.compatibility = Compatibility.ILLUSTRATOR24;
        saveOptions.compressed = true;
        saveOptions.pdfCompatible = true;
        
        var file = new File("{filename}");
        doc.saveAs(file, saveOptions);
        
        "Document saved to: " + file.fsName;
        """
        return await self.execute_script(script)
        
    async def export_as_png(self, filename):
        """Export the current document as PNG."""
        script = f"""
        var doc = app.activeDocument;
        var exportOptions = new ExportOptionsPNG24();
        exportOptions.antiAliasing = true;
        exportOptions.transparency = true;
        exportOptions.artBoardClipping = true;
        
        var file = new File("{filename}");
        doc.exportFile(file, ExportType.PNG24, exportOptions);
        
        "Exported to PNG: " + file.fsName;
        """
        return await self.execute_script(script)
        
    async def close(self):
        """Close the HTTP client."""
        await self.client.aclose()

# Test functions
@pytest.mark.asyncio
async def test_illustrator_connection():
    """Test basic connection to Illustrator."""
    tester = IllustratorTester()
    try:
        # Check services
        assert await tester.check_proxy_status(), "Proxy server not running"
        assert await tester.check_mcp_status(), "MCP server not running"
        
        # Create document
        result = await tester.create_test_document()
        assert "Document created" in result
        
    finally:
        await tester.close()

@pytest.mark.asyncio
async def test_logo_creation():
    """Test creating a logo design."""
    tester = IllustratorTester()
    try:
        await tester.create_test_document()
        result = await tester.create_logo_design()
        assert "Logo design created" in result
        
        # Save the logo
        import os
        docs_dir = os.path.join(os.environ['USERPROFILE'], 'Documents', 'Adobe_MCP_Tests')
        os.makedirs(docs_dir, exist_ok=True)
        save_path = os.path.join(docs_dir, "adobe_mcp_logo.ai").replace('\\', '/')
        result = await tester.save_document(save_path)
        assert "Document saved" in result
        
    finally:
        await tester.close()

@pytest.mark.asyncio
async def test_vector_illustration():
    """Test creating a vector illustration."""
    tester = IllustratorTester()
    try:
        await tester.create_test_document()
        result = await tester.create_vector_illustration()
        assert "Vector illustration created" in result
        
        # Export as PNG
        import os
        docs_dir = os.path.join(os.environ['USERPROFILE'], 'Documents', 'Adobe_MCP_Tests')
        os.makedirs(docs_dir, exist_ok=True)
        export_path = os.path.join(docs_dir, "adobe_mcp_illustration.png").replace('\\', '/')
        result = await tester.export_as_png(export_path)
        assert "Exported to PNG" in result
        
    finally:
        await tester.close()

async def main():
    """Run all tests."""
    print("Adobe Illustrator MCP Test Suite")
    print("================================")
    
    # Setup save directory
    import os
    docs_dir = os.path.join(os.environ['USERPROFILE'], 'Documents', 'Adobe_MCP_Tests')
    os.makedirs(docs_dir, exist_ok=True)
    print(f"\nSave directory: {docs_dir}")
    
    tester = IllustratorTester()
    
    try:
        # Check services first
        print("\n1. Checking services...")
        proxy_ok = await tester.check_proxy_status()
        mcp_ok = await tester.check_mcp_status()
        
        print(f"   Proxy Server: {'✓' if proxy_ok else '✗'}")
        print(f"   MCP Server: {'✓' if mcp_ok else '✗'}")
        
        if not (proxy_ok and mcp_ok):
            print("\nERROR: Required services not running!")
            print("Please start the proxy server and MCP server first.")
            return
            
        # Run tests
        print("\n2. Creating test document...")
        result = await tester.create_test_document()
        print(f"   Result: {result}")
        
        print("\n3. Creating logo design...")
        result = await tester.create_logo_design()
        print(f"   Result: {result}")
        
        print("\n4. Saving document...")
        save_path = os.path.join(docs_dir, "adobe_mcp_test.ai").replace('\\', '/')
        result = await tester.save_document(save_path)
        print(f"   Result: {result}")
        
        print("\n5. Creating vector illustration...")
        await tester.create_test_document()  # New document
        result = await tester.create_vector_illustration()
        print(f"   Result: {result}")
        
        print("\n6. Exporting as PNG...")
        export_path = os.path.join(docs_dir, "adobe_mcp_test.png").replace('\\', '/')
        result = await tester.export_as_png(export_path)
        print(f"   Result: {result}")
        
        print("\n✓ All tests completed successfully!")
        
    except Exception as e:
        print(f"\n✗ Test failed: {e}")
        
    finally:
        await tester.close()

if __name__ == "__main__":
    asyncio.run(main())