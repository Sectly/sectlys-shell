import QtQuick
import Quickshell

import qs.components
import qs.config

TooltipArea {
    implicitWidth: 20
    implicitHeight: 20

    text: "Launcher  (Super + Space)"

    Icon {
        source: Quickshell.iconPath("view-app-grid-symbolic")
        implicitSize: 18
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"])
    }
}
