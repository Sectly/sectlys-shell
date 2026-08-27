pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property var workspaces: []
    property var focusedWindow: null
    property var _windows: ({})
    property bool _connectedOnce: false

    signal connected()
    signal errorOccurred(string error)

    function connect() {
        eventStream.running = true
    }

    function focusWorkspaceById(wsId) {
        for (var i = 0; i < root.workspaces.length; i++) {
            if (root.workspaces[i].id === wsId) {
                focusCmd.command = ["niri", "msg", "action", "focus-workspace", String(root.workspaces[i].idx)]
                focusCmd.running = true
                return
            }
        }
    }

    property var _eventStream: Process {
        id: eventStream
        command: ["niri", "msg", "event-stream"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                var ev
                try { ev = JSON.parse(line) } catch(e) { return }

                var key = Object.keys(ev)[0]
                var data = ev[key]

                if (!root._connectedOnce) {
                    root._connectedOnce = true
                    root.connected()
                }

                if (key === "WorkspacesChanged") {
                    root.workspaces = data.workspaces.map(function(w) {
                        return {
                            id: w.id,
                            idx: w.idx,
                            isActive: w.is_active,
                            activeWindowId: w.active_window_id ?? 0
                        }
                    })
                } else if (key === "WindowOpenedOrChanged") {
                    var w = data.window
                    var wins = Object.assign({}, root._windows)
                    wins[w.id] = { appId: w.app_id ?? "", title: w.title ?? "" }
                    root._windows = wins
                } else if (key === "WindowClosed") {
                    var wins2 = Object.assign({}, root._windows)
                    delete wins2[data.id]
                    root._windows = wins2
                } else if (key === "WindowFocusChanged") {
                    var id = data.id
                    root.focusedWindow = (id !== null && root._windows[id]) ? root._windows[id] : null
                }
            }
        }

        onExited: function(code) {
            root.errorOccurred("niri event-stream exited with code " + code)
            root._connectedOnce = false
            restartTimer.start()
        }
    }

    property var _focusCmd: Process {
        id: focusCmd
        running: false
    }

    property var _restartTimer: Timer {
        id: restartTimer
        interval: 2000
        repeat: false
        onTriggered: {
            root.workspaces = []
            root.focusedWindow = null
            root._windows = {}
            eventStream.running = true
        }
    }
}
