/* MIT License
 *
 * Copyright (c) 2025 Adobe MCP Contributors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

const { entrypoints, UI } = require("uxp");
const {
    checkRequiresActiveDocument,
    parseAndRouteCommand,
} = require("./commands/index.js");

const { io } = require("./socket.io.js");
const app = require("illustrator").app;

const APPLICATION = "illustrator";
const PROXY_URL = "http://localhost:3001";

let socket = null;

const onCommandPacket = async (packet) => {
    let command = packet.command;

    let out = {
        senderId: packet.senderId,
    };

    try {
        //this will throw if an active document is required and not open
        checkRequiresActiveDocument(command);

        let response = await parseAndRouteCommand(command);

        out.response = response;
        out.status = "SUCCESS";

        let activeDocument = app.activeDocument;
        if (activeDocument) {
            out.document = {
                name: activeDocument.name,
                width: activeDocument.width,
                height: activeDocument.height,
                artboards: activeDocument.artboards.length,
                layers: activeDocument.layers.length
            };
        }
    } catch (e) {
        out.status = "FAILURE";
        out.message = `Error calling ${command.action} : ${e}`;
    }

    return out;
};

function connectToServer() {
    // Create new Socket.IO connection
    socket = io(PROXY_URL, {
        transports: ["websocket"],
    });

    socket.on("connect", () => {
        updateButton();
        console.log("Connected to server with ID:", socket.id);
        socket.emit("register", { application: APPLICATION });
    });

    socket.on("command_packet", async (packet) => {
        console.log("Received command packet:", packet);

        let response = await onCommandPacket(packet);
        sendResponsePacket(response);
    });

    socket.on("registration_response", (data) => {
        console.log("Received response:", data);
    });

    socket.on("connect_error", (error) => {
        updateButton();
        console.error("Connection error:", error);
    });

    socket.on("disconnect", () => {
        updateButton();
        console.log("Disconnected from server");
    });
}

function disconnectFromServer() {
    if (socket) {
        socket.disconnect();
        socket = null;
    }
    updateButton();
}

function sendResponsePacket(packet) {
    if (!socket || !socket.connected) {
        console.error("Socket is not connected. Cannot send response.");
        return;
    }

    socket.emit("command_packet_response", { packet });
}

// Panel setup
let connectButton = null;

const setupPanel = (rootNode) => {
    connectButton = document.createElement("button");
    connectButton.textContent = "Connect";
    connectButton.onclick = toggleConnection;
    rootNode.appendChild(connectButton);

    const statusDiv = document.createElement("div");
    statusDiv.id = "status";
    statusDiv.textContent = "Disconnected";
    rootNode.appendChild(statusDiv);
};

const toggleConnection = () => {
    if (!socket || !socket.connected) {
        connectToServer();
    } else {
        disconnectFromServer();
    }
};

const updateButton = () => {
    if (!connectButton) return;

    if (socket && socket.connected) {
        connectButton.textContent = "Disconnect";
        document.getElementById("status").textContent = "Connected";
    } else {
        connectButton.textContent = "Connect";
        document.getElementById("status").textContent = "Disconnected";
    }
};

entrypoints.setup({
    panels: {
        "com.adobemcp.illustrator.panel": {
            create(rootNode) {
                setupPanel(rootNode);
            },
        },
    },
});