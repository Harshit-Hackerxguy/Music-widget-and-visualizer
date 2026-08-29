import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris

PanelWindow {
    id: cardWindow

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-music-card"
    exclusionMode: ExclusionMode.Ignore

    // Anchor full-width so we can center the dynamic island horizontally
    anchors {
        top: true
        left: true
        right: true
    }
    
    // Top offset gap
    margins {
        top: 16
    }

    implicitHeight: 180
    color: "transparent"

    // CRITICAL FIX: Only the physical background (cardBg) accepts clicks.
    // The rest of this transparent full-width window passes clicks down to Firefox.
    mask: Region {
        item: cardBg
    }

    // Dynamic Island State tracking
    property bool isExpanded: true

    Timer {
        id: collapseTimer
        interval: 3000
        running: true // Starts counting down immediately upon spawn
        onTriggered: {
            cardWindow.isExpanded = false
        }
    }

    readonly property MprisPlayer activePlayer: {
        const list = Mpris.players.values;
        if (!list || list.length === 0) return null;
        const playing = list.find(p => p.isPlaying || p.playbackState === MprisPlaybackState.Playing);
        return playing || list[0];
    }

    Timer {
        interval: 1000
        running: cardWindow.activePlayer && cardWindow.activePlayer.isPlaying
        repeat: true
        onTriggered: {
            if (cardWindow.activePlayer) cardWindow.activePlayer.positionChanged();
        }
    }

    function formatTime(seconds) {
        if (!seconds || isNaN(seconds) || seconds <= 0) return "00:00";
        var m = Math.floor(seconds / 60);
        var s = Math.floor(seconds % 60);
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    // The Container Box that physically animates between expanded/island states
    Rectangle {
        id: cardBg
        clip: true // Automatically hides the overflow as it shrinks
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        
        // Fluid Sizing based on the isExpanded boolean
        width: cardWindow.isExpanded ? 440 : 220
        height: cardWindow.isExpanded ? 160 : 40
        radius: cardWindow.isExpanded ? 18 : 20
        
        color: Qt.rgba(0.07, 0.08, 0.12, 0.85)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
        border.width: 1

        // Smooth physical resizing animations
        Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
        Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
        Behavior on radius { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

        // Hover logic wrapper
        HoverHandler {
            onHoveredChanged: {
                if (hovered) {
                    cardWindow.isExpanded = true;
                    collapseTimer.stop();
                } else {
                    // Start 3-second countdown when mouse leaves
                    collapseTimer.restart();
                }
            }
        }

        // ==========================================
        // LAYER 1: COMPACT VIEW (Dynamic Island)
        // ==========================================
        Item {
            anchors.fill: parent
            opacity: cardWindow.isExpanded ? 0 : 1
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8
                
                Text {
                    text: (cardWindow.activePlayer && cardWindow.activePlayer.isPlaying) ? "🎵" : "⏸"
                    font.pixelSize: 13
                }
                
                Text {
                    Layout.fillWidth: true
                    text: cardWindow.activePlayer ? (cardWindow.activePlayer.trackTitle || "Nothing Playing") : "No Media"
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.bold: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        // ==========================================
        // LAYER 2: EXPANDED VIEW (Music Card)
        // ==========================================
        Item {
            anchors.fill: parent
            opacity: cardWindow.isExpanded ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Album Thumbnail
                Rectangle {
                    Layout.preferredWidth: 128
                    Layout.preferredHeight: 128
                    radius: 12
                    color: "#141620"
                    clip: true
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.08)

                    Image {
                        anchors.fill: parent
                        source: cardWindow.activePlayer ? (cardWindow.activePlayer.trackArtUrl || "") : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "🎵"
                        font.pixelSize: 40
                        opacity: 0.4
                        visible: !cardWindow.activePlayer || !cardWindow.activePlayer.trackArtUrl
                    }
                }

                // Controls & Track Info
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    Text {
                        text: cardWindow.activePlayer ? (cardWindow.activePlayer.identity || "Media Player").toUpperCase() : "NO MEDIA"
                        color: "#00d2ff"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        text: cardWindow.activePlayer ? (cardWindow.activePlayer.trackTitle || "No Track Title") : "Nothing Playing"
                        color: "#ffffff"
                        font.pixelSize: 15
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: cardWindow.activePlayer ? (cardWindow.activePlayer.trackArtist || "Unknown Artist") : "Play audio to visualize"
                        color: "#a0a5b5"
                        font.pixelSize: 12
                        elide: Text.ElideRight
                    }

                    Item { Layout.fillHeight: true }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Rectangle {
                            Layout.fillWidth: true
                            height: 4
                            radius: 2
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.15)

                            Rectangle {
                                height: parent.height
                                radius: parent.radius
                                color: "#00d2ff"
                                width: {
                                    if (!cardWindow.activePlayer || !cardWindow.activePlayer.length || cardWindow.activePlayer.length <= 0) return 0;
                                    var progress = cardWindow.activePlayer.position / cardWindow.activePlayer.length;
                                    return parent.width * Math.min(1.0, Math.max(0.0, progress));
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: cardWindow.activePlayer ? cardWindow.formatTime(cardWindow.activePlayer.position) : "00:00"
                                color: "#7a8092"
                                font.pixelSize: 10
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: cardWindow.activePlayer ? cardWindow.formatTime(cardWindow.activePlayer.length) : "00:00"
                                color: "#7a8092"
                                font.pixelSize: 10
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 16

                        Rectangle {
                            width: 30; height: 30; radius: 15
                            color: prevMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "⏮"
                                color: cardWindow.activePlayer && cardWindow.activePlayer.canGoPrevious ? "#ffffff" : "#4a4e5d"
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: if (cardWindow.activePlayer && cardWindow.activePlayer.canGoPrevious) cardWindow.activePlayer.previous()
                            }
                        }

                        Rectangle {
                            width: 36; height: 36; radius: 18
                            color: "#00d2ff"
                            Text {
                                anchors.centerIn: parent
                                text: (cardWindow.activePlayer && cardWindow.activePlayer.isPlaying) ? "⏸" : "▶"
                                color: "#0c0e14"
                                font.pixelSize: 15
                                font.bold: true
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: if (cardWindow.activePlayer && cardWindow.activePlayer.canTogglePlaying) cardWindow.activePlayer.togglePlaying()
                            }
                        }

                        Rectangle {
                            width: 30; height: 30; radius: 15
                            color: nextMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                            Text {
                                anchors.centerIn: parent
                                text: "⏭"
                                color: cardWindow.activePlayer && cardWindow.activePlayer.canGoNext ? "#ffffff" : "#4a4e5d"
                                font.pixelSize: 13
                            }
                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: if (cardWindow.activePlayer && cardWindow.activePlayer.canGoNext) cardWindow.activePlayer.next()
                            }
                        }
                    }
                }
            }
        }
    }
}
