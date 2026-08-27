pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import qs.components
import qs.config
import qs.services

PanelWindow {
    id: root

    visible: false
    anchors {
        right: true
        top: true
    }
    implicitWidth: 300
    implicitHeight: panel.implicitHeight + Appearance.spacing.large * 2
    color: "transparent"

    FileView {
        path: "/tmp/qs-ipc/settings"
        watchChanges: true
        property bool initialized: false
        Timer { interval: 200; running: true; repeat: false; onTriggered: parent.initialized = true }
        onTextChanged: if (initialized) root.visible = !root.visible
    }

    Keys.onEscapePressed: root.visible = false

    // Click outside to close via bar button toggle

    Rectangle {
        id: panel
        anchors {
            top: parent.top
            right: parent.right
            margins: Appearance.spacing.normal
        }
        width: 280
        height: implicitHeight
        implicitHeight: panelContent.implicitHeight + Appearance.spacing.large * 2
        radius: Appearance.rounding.large
        color: Appearance.colors.surface
        border.color: Appearance.colors.outline_variant

        ColumnLayout {
            id: panelContent
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Appearance.spacing.large
            }
            spacing: Appearance.spacing.normal

            // Header
            StyledText {
                text: "Settings"
                font.pixelSize: Appearance.fontSize.md
                font.bold: true
                color: Appearance.colors.on_surface
            }

            Rectangle { height: 1; Layout.fillWidth: true; color: Appearance.colors.outline_variant }

            // Clock format
            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: "24-hour clock"
                    font.pixelSize: Appearance.fontSize.sm
                    color: Appearance.colors.on_surface
                    Layout.fillWidth: true
                }

                // Toggle pill
                Rectangle {
                    id: toggle
                    width: 44
                    height: 24
                    radius: 12
                    color: ShellSettings.use24h ? Appearance.colors.primary : Appearance.colors.surface_container_high

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Rectangle {
                        id: thumb
                        width: 18
                        height: 18
                        radius: 9
                        color: ShellSettings.use24h ? Appearance.colors.on_primary : Appearance.colors.on_surface_variant
                        anchors.verticalCenter: parent.verticalCenter
                        x: ShellSettings.use24h ? parent.width - width - 3 : 3

                        Behavior on x { NumberAnimation { duration: 120 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ShellSettings.toggle24h()
                    }
                }
            }

            Rectangle { height: 1; Layout.fillWidth: true; color: Appearance.colors.outline_variant }

            // Theme picker
            StyledText {
                text: "Theme"
                font.pixelSize: Appearance.fontSize.sm
                font.bold: true
                color: Appearance.colors.on_surface_variant
            }

            Column {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ShellSettings.themes

                    delegate: Rectangle {
                        id: themeRow
                        required property string modelData
                        width: parent.width
                        height: themeLabel.implicitHeight + Appearance.padding.normal * 2
                        radius: Appearance.rounding.small
                        color: ShellSettings.currentTheme === themeRow.modelData
                            ? Appearance.colors.primary_container
                            : hovered ? Appearance.colors.surface_container : "transparent"

                        property bool hovered: false

                        StyledText {
                            id: themeLabel
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                                leftMargin: Appearance.padding.normal
                            }
                            text: themeRow.modelData.replace(/-/g, " ")
                            font.pixelSize: Appearance.fontSize.xs
                            color: ShellSettings.currentTheme === themeRow.modelData
                                ? Appearance.colors.on_primary_container
                                : Appearance.colors.on_surface
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: themeRow.hovered = true
                            onExited: themeRow.hovered = false
                            onClicked: ShellSettings.setTheme(themeRow.modelData)
                        }
                    }
                }
            }

            Rectangle { height: 1; Layout.fillWidth: true; color: Appearance.colors.outline_variant }

            // Wallpaper picker
            StyledText {
                text: "Wallpaper"
                font.pixelSize: Appearance.fontSize.sm
                font.bold: true
                color: Appearance.colors.on_surface_variant
            }

            Column {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: ShellSettings.availableWallpapers

                    delegate: Rectangle {
                        id: wallRow
                        required property var modelData
                        width: parent.width
                        height: wallLabel.implicitHeight + Appearance.padding.normal * 2
                        radius: Appearance.rounding.small
                        color: ShellSettings.currentWallpaper === wallRow.modelData.path
                            ? Appearance.colors.primary_container
                            : hovered ? Appearance.colors.surface_container : "transparent"

                        property bool hovered: false

                        StyledText {
                            id: wallLabel
                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                                leftMargin: Appearance.padding.normal
                            }
                            text: wallRow.modelData.name
                            font.pixelSize: Appearance.fontSize.xs
                            color: ShellSettings.currentWallpaper === wallRow.modelData.path
                                ? Appearance.colors.on_primary_container
                                : Appearance.colors.on_surface
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: wallRow.hovered = true
                            onExited: wallRow.hovered = false
                            onClicked: ShellSettings.setWallpaper(wallRow.modelData.path)
                        }
                    }
                }

                StyledText {
                    visible: ShellSettings.availableWallpapers.length === 0
                    text: "No wallpapers in ~/Pictures/Wallpapers"
                    font.pixelSize: Appearance.fontSize.xs
                    color: Appearance.colors.on_surface_variant
                    leftPadding: Appearance.padding.normal
                }
            }

            Rectangle { height: 1; Layout.fillWidth: true; color: Appearance.colors.outline_variant }

            // Version info
            StyledText {
                text: "Sectly's Shell v" + ShellSettings.version
                font.pixelSize: Appearance.fontSize.xs
                color: Appearance.colors.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
                bottomPadding: Appearance.spacing.small
            }
        }
    }
}
