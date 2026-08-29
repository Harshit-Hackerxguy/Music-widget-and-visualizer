import QtQuick
import Quickshell

ShellRoot {
    id: root

    // Layer 1: Background Layer (WlrLayer.Bottom)
    Visualizer {}

    // Layer 2: Floating Card Layer (WlrLayer.Top)
    MusicCard {}

}
