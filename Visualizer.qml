import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: visualizerWin

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-music-visualizer"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        left: true
        right: true
    }

    property real visualizerHeightRatio: 0.28
    implicitHeight: screen ? Math.round(screen.height * visualizerHeightRatio) : 300
    color: "transparent"
    
    // Keeps the visualizer 100% click-through
    mask: Region {}

    // --- RGB GLOW ANIMATION ---
    // This property smoothly loops from 0.0 to 1.0 over 8 seconds.
    // In the HSV color space, this creates a perfect Red -> Green -> Blue cycle.
    property real rgbHue: 0.0
    NumberAnimation on rgbHue {
        from: 0.0
        to: 1.0
        duration: 8000 // 8 seconds per full color cycle
        loops: Animation.Infinite
    }

    // Top ambient RGB backdrop glow
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            // Qt.hsva(hue, saturation, value, alpha)
            GradientStop { position: 0.0; color: Qt.hsva(visualizerWin.rgbHue, 0.9, 1.0, 0.15) }
            GradientStop { position: 0.6; color: Qt.hsva(visualizerWin.rgbHue, 0.9, 0.8, 0.04) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Full-width Audio Bars
    Row {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        spacing: 2

        Repeater {
            model: CavaService.barCount

            Rectangle {
                width: (parent.width - (CavaService.barCount - 1) * 2) / CavaService.barCount
                
                property real barValue: (CavaService.values && CavaService.values[index] !== undefined) 
                                        ? CavaService.values[index] / 100.0 
                                        : 0.0

                height: Math.max(2, parent.height * barValue)

                Behavior on height {
                    NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
                }

                radius: width / 2

                // RGB Gradient for the audio bars bound to the same hue animation
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.hsva(visualizerWin.rgbHue, 0.85, 1.0, 0.85) }
                    GradientStop { position: 0.5; color: Qt.hsva(visualizerWin.rgbHue, 0.95, 0.9, 0.45) }
                    GradientStop { position: 1.0; color:


 Qt.hsva(visualizerWin.rgbHue, 1.0, 0.6, 0.0) }
                }
            }
        }
    }
}
