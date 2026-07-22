import QtQuick
import Quickshell
import Quickshell.Io

import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property real diskPercent: 0.0
    property bool showLabel: pluginData.showLabel !== false
    property string labelText: pluginData.labelText || "DISK"
    property bool combineAll: pluginData.combineAll === true
    property bool includeExternal: pluginData.includeExternal === true
    property int topCount: pluginData.topCount || 30
    property var rows: []

    function usageColor(percent) {
        if (percent > 90) return Theme.error
        if (percent > 75) return "#ffa500"
        return Theme.primary
    }

    function fmtSize(bytes) {
        if (bytes >= 1099511627776) return (bytes / 1099511627776).toFixed(1) + " TB"
        return Math.round(bytes / 1073741824) + " GB"
    }

    // Disks move slowly; a frequent poll is wasted work.
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: diskProcess.running = true
    }

    Process {
        id: diskProcess
        command: ["sh", Qt.resolvedUrl("collect.sh").toString().replace("file://", "")]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const out = []
                for (const line of text.trim().split("\n")) {
                    const f = line.split("\t")
                    if (f[0] === "R" && !root.combineAll) root.diskPercent = parseInt(f[1])
                    if (f[0] === "C" && root.combineAll && !root.includeExternal) root.diskPercent = parseInt(f[1])
                    if (f[0] === "CX" && root.combineAll && root.includeExternal) root.diskPercent = parseInt(f[1])
                    if (f[0] === "X" && !root.includeExternal) continue
                    if ((f[0] !== "S" && f[0] !== "X") || f.length < 6) continue
                    const used = parseInt(f[1])
                    const size = parseInt(f[5])
                    out.push({
                        used: used,
                        name: f[3],
                        detail: root.fmtSize(size) + (f[4] ? ", " + f[4] : ""),
                        share: size > 0 ? used / size : 0
                    })
                }
                out.sort((a, b) => b.used - a.used)
                root.rows = out.slice(0, root.topCount)
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "hard_drive"
                size: Theme.fontSizeLarge
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: root.showLabel
                text: root.labelText
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle {
                width: 44
                height: 6
                radius: 3
                color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.25)
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: parent.width * Math.min(root.diskPercent, 100) / 100
                    height: parent.height
                    radius: parent.radius
                    color: root.usageColor(root.diskPercent)
                    Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 400 } }
                }
            }

            StyledText {
                width: 34
                horizontalAlignment: Text.AlignRight
                text: `${root.diskPercent.toFixed(0)}%`
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    popoutWidth: 340

    popoutContent: Component {
        PopoutComponent {
            id: popout

            Item {
                width: parent.width
                implicitHeight: rows.implicitHeight + Theme.spacingM * 2

                Column {
                    id: rows
                    x: Theme.spacingM
                    y: Theme.spacingM
                    width: parent.width - Theme.spacingM * 2
                    spacing: Theme.spacingXS

                    Repeater {
                        model: root.rows

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Row {
                                width: parent.width - stats.width - Theme.spacingS
                                spacing: 5
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    id: mountName
                                    width: Math.min(implicitWidth, parent.width)
                                    text: modelData.name
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    width: parent.width - mountName.width - parent.spacing
                                    visible: modelData.detail.length > 0
                                    text: modelData.detail
                                    font.pixelSize: Theme.fontSizeSmall - 1
                                    color: Theme.surfaceVariantText
                                    opacity: 0.55
                                    wrapMode: Text.NoWrap
                                    maximumLineCount: 1
                                    elide: Text.ElideRight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Row {
                                id: stats
                                spacing: 4
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    width: 56
                                    horizontalAlignment: Text.AlignRight
                                    text: root.fmtSize(modelData.used)
                                    font.pixelSize: Theme.fontSizeSmall - 1
                                    color: Theme.surfaceVariantText
                                    opacity: 0.7
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Rectangle {
                                    width: 40
                                    height: 4
                                    radius: 2
                                    color: Qt.rgba(Theme.surfaceText.r, Theme.surfaceText.g, Theme.surfaceText.b, 0.25)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Rectangle {
                                        width: parent.width * Math.min(modelData.share, 1)
                                        height: parent.height
                                        radius: parent.radius
                                        color: root.usageColor(modelData.share * 100)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
