import QtQuick
import Quickshell

import qs.components
import qs.config

TooltipArea {
    implicitWidth: 16
    implicitHeight: 16

    text: "Settings"

    Icon {
        source: Quickshell.iconPath("preferences-system-symbolic")
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["qs", "ipc", "call", "settings", "toggle"])
    }
}
