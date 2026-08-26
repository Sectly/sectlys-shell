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
    aboveWindows: false
    focusable: true
    color: "transparent"

    property string flagFile: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.config/sectlys-shell/welcomed"

    Process {
        id: checkFlag
        command: ["sh", "-c", "test -f '" + root.flagFile + "'"]
        onExited: (code) => {
            if (code !== 0) root.visible = true;
        }
        Component.onCompleted: running = true
    }

    Process {
        id: writeFlag
        command: ["sh", "-c", "mkdir -p \"$(dirname '" + root.flagFile + "')\" && touch '" + root.flagFile + "'"]
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismiss()
    }

    function dismiss() {
        writeFlag.running = true;
        root.visible = false;
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(520, parent.width - Appearance.spacing.large * 4)
        height: content.implicitHeight + Appearance.spacing.large * 2
        radius: Appearance.rounding.large
        color: Appearance.colors.surface
        border.color: Appearance.colors.outline_variant

        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Appearance.spacing.large
            }
            spacing: Appearance.spacing.normal

            StyledText {
                text: "Sectly's Shell"
                font.pixelSize: Appearance.fontSize.xxl
                font.bold: true
                color: Appearance.colors.primary
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                text: "A ready-to-use Niri desktop on Void Linux."
                font.pixelSize: Appearance.fontSize.sm
                color: Appearance.colors.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Appearance.colors.outline_variant
            }

            WelcomeSection {
                title: "Applications"
                rows: [
                    ["Super + Space",   "Launcher"],
                    ["Super + E",       "Files (Nautilus)"],
                    ["Super + B",       "Browser (Helium)"],
                    ["Ctrl + Alt + T",  "Terminal (Alacritty)"],
                ]
            }

            WelcomeSection {
                title: "Software"
                rows: [
                    ["Bazaar",    "Browse & install Flatpak apps"],
                    ["OctoXBPS",  "Browse & install system packages"],
                    ["Zed",       "Code editor"],
                    ["Steam",     "Gaming"],
                ]
            }

            WelcomeSection {
                title: "Useful scripts"
                rows: [
                    ["Super + Shift + S",   "Open settings panel"],
                    ["wallpaper search",    "Browse & download wallpapers"],
                    ["scripts/update",      "Update all packages"],
                    ["scripts/reset-config","Restore default configs"],
                    ["Super + Shift + /",   "Open keybinds reference"],
                ]
            }

            Rectangle {
                height: 1
                Layout.fillWidth: true
                color: Appearance.colors.outline_variant
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: Appearance.spacing.small
                radius: Appearance.rounding.normal
                color: Appearance.colors.primary
                implicitWidth: dismissLabel.implicitWidth + Appearance.padding.large * 2
                implicitHeight: dismissLabel.implicitHeight + Appearance.padding.normal * 2

                StyledText {
                    id: dismissLabel
                    anchors.centerIn: parent
                    text: "Got it"
                    font.pixelSize: Appearance.fontSize.sm
                    font.bold: true
                    color: Appearance.colors.on_primary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.dismiss()
                }
            }
        }
    }

    component WelcomeSection: ColumnLayout {
        id: section
        required property string title
        required property var rows
        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        StyledText {
            text: section.title
            font.pixelSize: Appearance.fontSize.xs
            font.bold: true
            color: Appearance.colors.primary
        }

        Repeater {
            model: section.rows
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                Rectangle {
                    radius: Appearance.rounding.small
                    color: Appearance.colors.surface_container_high
                    implicitWidth: keyText.implicitWidth + Appearance.padding.normal * 2
                    implicitHeight: keyText.implicitHeight + Appearance.padding.small

                    StyledText {
                        id: keyText
                        anchors.centerIn: parent
                        text: modelData[0]
                        font.pixelSize: Appearance.fontSize.xs
                        font.family: Appearance.font.mono
                        color: Appearance.colors.on_surface
                    }
                }

                StyledText {
                    text: modelData[1]
                    font.pixelSize: Appearance.fontSize.xs
                    color: Appearance.colors.on_surface_variant
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }
    }
}
