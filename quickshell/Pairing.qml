pragma Singleton

import QtQuick
import Quickshell

// A Bluetooth pairing request waiting on an answer. scripts/a4a-bt-agent is the BlueZ
// agent: when a device asks to pair it sends the request here over IPC
// (`quickshell ipc call pairing request …`), the control centre opens on the pairing
// card, and the answer goes back to the agent on the session bus.
//
// Kinds:
//   confirm    both sides show a code; pair if they match
//   authorize  a device asks to pair, no code
//   service    a device that isn't trusted asks to use a service (code: its name)
//   pin        the device wants a PIN typed here (legacy devices; often 0000)
//   passkey    the device wants a 6-digit passkey typed here
//   display    type the code shown here on the device (keyboards), then Enter
Singleton {
    id: root

    // {id, kind, device, code, entered}, or null.
    property var request: null
    // Whether a panel was open before the request, so answering returns there.
    property bool wasOpen: false
    property string returnView: ""

    function receive(id, kind, device, code) {
        if (request !== null && request.id !== id)
            answer(false, "")
        wasOpen = IslandState.open && IslandState.view !== "pairing"
        returnView = wasOpen ? IslandState.view : ""
        request = { id: id, kind: kind, device: device, code: code, entered: 0 }
        IslandState.openTo("pairing")
    }

    // How many digits have been typed on the keyboard so far (display kind).
    function progress(id, entered) {
        if (request !== null && request.id === id)
            request = Object.assign({}, request, { entered: entered })
    }

    // BlueZ gave up (the device cancelled, or it timed out), or pairing finished.
    function cancel(id) {
        if (request !== null && request.id === id)
            finish()
    }

    function answer(accept, value) {
        if (request === null)
            return
        Quickshell.execDetached(["busctl", "--user", "call", "com.a4a.BtAgent", "/com/a4a/BtAgent",
            "com.a4a.BtAgent", "Reply", "ubs", String(request.id), accept ? "true" : "false", value])
        finish()
    }

    function finish() {
        request = null
        if (IslandState.view !== "pairing")
            return
        if (wasOpen)
            IslandState.view = returnView
        else
            IslandState.close()
    }

    // Leaving the card (closing the panel, another page) is a no: a request left
    // hanging would hold the device in pairing until BlueZ times it out.
    Connections {
        target: IslandState
        function onOpenChanged() {
            if (!IslandState.open && root.request !== null)
                root.answer(false, "")
        }
        function onViewChanged() {
            if (IslandState.view !== "pairing" && root.request !== null)
                root.answer(false, "")
        }
    }
}
