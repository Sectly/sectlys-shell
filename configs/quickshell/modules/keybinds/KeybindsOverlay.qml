pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.components
import qs.config

PanelWindow {
    id: root

    visible: false
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    aboveWindows: true
    focusable: true
    color: "transparent"

    FileView {
        id: keybindsIpc
        path: "/tmp/qs-ipc/keybinds"
        watchChanges: true
        property bool initialized: false
        onTextChanged: if (initialized) root.visible = !root.visible
    }
    Timer { interval: 200; running: true; repeat: false; onTriggered: keybindsIpc.initialized = true }

    Keys.onEscapePressed: root.visible = false

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(760, parent.width - Appearance.spacing.large * 4)
        height: Math.min(560, parent.height - Appearance.spacing.large * 4)
        radius: Appearance.rounding.large
        color: Appearance.colors.surface
        border.color: Appearance.colors.outline_variant

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            anchors {
                fill: parent
                margins: Appearance.spacing.large
            }
            spacing: Appearance.spacing.normal

            StyledText {
                text: "Keyboard Shortcuts"
                font.pixelSize: Appearance.fontSize.lg
                font.bold: true
                color: Appearance.colors.primary
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Appearance.colors.outline_variant
            }

            Row {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Appearance.spacing.large

                Column {
                    width: parent.width / 3
                    spacing: Appearance.spacing.small

                    KeybindCategory { label: "Applications" }
                    KeybindRow { keys: "Ctrl + Alt + T";   action: "Terminal" }
                    KeybindRow { keys: "Super + Enter";    action: "Terminal" }
                    KeybindRow { keys: "Super + E";        action: "Files" }
                    KeybindRow { keys: "Super + B";        action: "Browser" }
                    KeybindRow { keys: "Super + Space";    action: "Launcher" }

                    Item { height: Appearance.spacing.small; width: 1 }

                    KeybindCategory { label: "Windows" }
                    KeybindRow { keys: "Super + Q";           action: "Close" }
                    KeybindRow { keys: "Super + F";           action: "Maximize column" }
                    KeybindRow { keys: "Super + Shift + F";   action: "Fullscreen" }
                    KeybindRow { keys: "Super + R";           action: "Cycle width" }
                    KeybindRow { keys: "Super + - / =";       action: "Resize column" }
                }

                Column {
                    width: parent.width / 3
                    spacing: Appearance.spacing.small

                    KeybindCategory { label: "Focus" }
                    KeybindRow { keys: "Super + H / L";       action: "Column left / right" }
                    KeybindRow { keys: "Super + J / K";       action: "Window down / up" }
                    KeybindRow { keys: "Super + Arrows";      action: "Same as above" }

                    Item { height: Appearance.spacing.small; width: 1 }

                    KeybindCategory { label: "Move" }
                    KeybindRow { keys: "Super + Shift + H/L"; action: "Move column" }
                    KeybindRow { keys: "Super + Shift + J/K"; action: "Move window" }

                    Item { height: Appearance.spacing.small; width: 1 }

                    KeybindCategory { label: "Workspaces" }
                    KeybindRow { keys: "Super + 1–9";         action: "Switch workspace" }
                    KeybindRow { keys: "Super + Shift + 1–9"; action: "Move to workspace" }
                    KeybindRow { keys: "Super + Tab";         action: "Next workspace" }
                    KeybindRow { keys: "Super + Shift + Tab"; action: "Prev workspace" }
                }

                Column {
                    width: parent.width / 3
                    spacing: Appearance.spacing.small

                    KeybindCategory { label: "Screenshots" }
                    KeybindRow { keys: "Print";             action: "Region screenshot" }
                    KeybindRow { keys: "Shift + Print";     action: "Full screen" }
                    KeybindRow { keys: "Ctrl + Print";      action: "Focused window" }

                    Item { height: Appearance.spacing.small; width: 1 }

                    KeybindCategory { label: "Media" }
                    KeybindRow { keys: "Volume keys";       action: "Volume up / down / mute" }
                    KeybindRow { keys: "Brightness keys";   action: "Brightness up / down" }
                    KeybindRow { keys: "Media keys";        action: "Play / next / prev" }

                    Item { height: Appearance.spacing.small; width: 1 }

                    KeybindCategory { label: "System" }
                    KeybindRow { keys: "Super + Shift + L"; action: "Lock screen" }
                    KeybindRow { keys: "Super + Shift + /"; action: "This overlay" }
                    KeybindRow { keys: "Super + Shift + S"; action: "Settings panel" }
                    KeybindRow { keys: "Super + Shift + P"; action: "Monitors off" }
                    KeybindRow { keys: "Super + Shift + E"; action: "Quit Niri" }
                }
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Appearance.colors.outline_variant
            }

            StyledText {
                text: "Press Escape or click outside to close"
                font.pixelSize: Appearance.fontSize.xs
                color: Appearance.colors.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    component KeybindCategory: StyledText {
        font.pixelSize: Appearance.fontSize.xs
        font.bold: true
        color: Appearance.colors.primary
        topPadding: Appearance.spacing.small
    }

    component KeybindRow: RowLayout {
        required property string keys
        required property string action
        width: parent.width
        spacing: Appearance.spacing.small

        Rectangle {
            radius: Appearance.rounding.small
            color: Appearance.colors.surface_container_high
            implicitWidth: keysLabel.implicitWidth + Appearance.padding.normal * 2
            implicitHeight: keysLabel.implicitHeight + Appearance.padding.small * 2

            StyledText {
                id: keysLabel
                anchors.centerIn: parent
                text: parent.parent.keys
                font.pixelSize: Appearance.fontSize.xs
                font.family: Appearance.font.mono
                color: Appearance.colors.on_surface
            }
        }

        StyledText {
            text: parent.action
            font.pixelSize: Appearance.fontSize.xs
            color: Appearance.colors.on_surface_variant
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }
}
