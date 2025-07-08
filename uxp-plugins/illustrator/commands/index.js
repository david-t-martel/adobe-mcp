/* MIT License
 *
 * Copyright (c) 2025 Adobe MCP Contributors
 */

const { app, constants } = require("illustrator");
const { batchPlay } = require("illustrator").action;

const commandHandlers = {
    executeScript: async (params) => {
        try {
            // Execute JavaScript code within Illustrator
            const result = await eval(params.code);
            return { result: result || "Script executed successfully" };
        } catch (e) {
            throw new Error(`Script execution failed: ${e.message}`);
        }
    },

    createDocument: async (params) => {
        const doc = app.documents.add({
            documentColorSpace: params.colorSpace || constants.DocumentColorSpace.RGB,
            width: params.width || 800,
            height: params.height || 600,
            title: params.title || "Untitled"
        });
        return { documentId: doc.id, name: doc.name };
    },

    createPath: async (params) => {
        const doc = app.activeDocument;
        if (!doc) throw new Error("No active document");

        const path = doc.pathItems.add();
        path.setEntirePath(params.points);
        
        if (params.fill) {
            path.filled = true;
            path.fillColor = createColor(params.fill);
        }
        
        if (params.stroke) {
            path.stroked = true;
            path.strokeColor = createColor(params.stroke);
            path.strokeWidth = params.strokeWidth || 1;
        }

        return { pathId: path.uuid };
    },

    createShape: async (params) => {
        const doc = app.activeDocument;
        if (!doc) throw new Error("No active document");

        let shape;
        switch (params.type) {
            case "rectangle":
                shape = doc.pathItems.rectangle(
                    params.top || 0,
                    params.left || 0,
                    params.width || 100,
                    params.height || 100
                );
                break;
            case "ellipse":
                shape = doc.pathItems.ellipse(
                    params.top || 0,
                    params.left || 0,
                    params.width || 100,
                    params.height || 100
                );
                break;
            case "star":
                shape = doc.pathItems.star(
                    params.centerX || 50,
                    params.centerY || 50,
                    params.radius || 50,
                    params.innerRadius || 25,
                    params.points || 5
                );
                break;
            default:
                throw new Error(`Unknown shape type: ${params.type}`);
        }

        if (params.fill) {
            shape.filled = true;
            shape.fillColor = createColor(params.fill);
        }

        if (params.stroke) {
            shape.stroked = true;
            shape.strokeColor = createColor(params.stroke);
            shape.strokeWidth = params.strokeWidth || 1;
        }

        return { shapeId: shape.uuid };
    },

    createText: async (params) => {
        const doc = app.activeDocument;
        if (!doc) throw new Error("No active document");

        const text = doc.textFrames.add();
        text.contents = params.text || "Sample Text";
        text.position = [params.x || 100, params.y || 100];

        if (params.fontSize) {
            text.textRange.characterAttributes.size = params.fontSize;
        }

        if (params.font) {
            try {
                const font = app.textFonts.getByName(params.font);
                text.textRange.characterAttributes.textFont = font;
            } catch (e) {
                console.warn(`Font ${params.font} not found`);
            }
        }

        if (params.color) {
            text.textRange.characterAttributes.fillColor = createColor(params.color);
        }

        return { textId: text.uuid };
    },

    getDocumentInfo: async () => {
        const doc = app.activeDocument;
        if (!doc) throw new Error("No active document");

        return {
            name: doc.name,
            width: doc.width,
            height: doc.height,
            colorSpace: doc.documentColorSpace,
            artboards: doc.artboards.length,
            layers: doc.layers.length,
            selection: doc.selection.length
        };
    },

    exportDocument: async (params) => {
        const doc = app.activeDocument;
        if (!doc) throw new Error("No active document");

        const exportOptions = new ExportOptionsWebOptimizedSVG();
        exportOptions.artboardRange = params.artboardRange || "";
        exportOptions.coordinatePrecision = params.precision || 3;
        
        const file = new File(params.path);
        doc.exportFile(file, ExportType.WOSVG, exportOptions);

        return { exported: true, path: params.path };
    }
};

function createColor(colorSpec) {
    const color = new RGBColor();
    if (typeof colorSpec === "string") {
        // Handle hex colors
        const hex = colorSpec.replace("#", "");
        color.red = parseInt(hex.substr(0, 2), 16);
        color.green = parseInt(hex.substr(2, 2), 16);
        color.blue = parseInt(hex.substr(4, 2), 16);
    } else {
        color.red = colorSpec.r || 0;
        color.green = colorSpec.g || 0;
        color.blue = colorSpec.b || 0;
    }
    return color;
}

async function parseAndRouteCommand(command) {
    const handler = commandHandlers[command.action];
    if (!handler) {
        throw new Error(`Unknown command action: ${command.action}`);
    }
    return await handler(command.params || {});
}

function checkRequiresActiveDocument(command) {
    const requiresDoc = [
        "createPath", "createShape", "createText", 
        "getDocumentInfo", "exportDocument"
    ];
    
    if (requiresDoc.includes(command.action) && !app.activeDocument) {
        throw new Error(`Command ${command.action} requires an active document`);
    }
}

module.exports = {
    parseAndRouteCommand,
    checkRequiresActiveDocument,
    commandHandlers
};