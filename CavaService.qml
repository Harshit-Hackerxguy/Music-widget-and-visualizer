pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var values: []
    property int barCount: 48
    property bool active: true

    Component.onCompleted: {
        var initial = [];
        for (var i = 0; i < barCount; i++) {
            initial.push(0);
        }
        values = initial;
    }

    Process {
        id: cavaProc
        command: ["cava", "-p", Qt.resolvedUrl("./cava.conf").toString().replace("file://", "")]
        running: root.active

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data) return;
                var rawValues = data.trim().split(";");
                var parsed = [];
                for (var i = 0; i < root.barCount; i++) {
                    var val = parseInt(rawValues[i]) || 0;
                    parsed.push(Math.min(100, Math.max(0, val)));
                }
                root.values = parsed;
            }
        }
    }
}
