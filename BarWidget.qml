import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property QtObject bar: null
  property string moduleName: "shusui.flow-dictation"
  property var settings: ({})
  property bool recording: false

  readonly property string home: Quickshell.env("HOME") || ""
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || home + "/.config"
  readonly property string commandPath: configHome + "/omarchy/plugins/" + moduleName + "/flow_dictation.py"
  readonly property string tooltip: recording
    ? "Flow Dictation is recording — click to stop and insert text"
    : "Flow Dictation — click to start recording"

  implicitWidth: bar && bar.vertical ? bar.barSize : 27
  implicitHeight: bar && !bar.vertical ? bar.barSize : 27

  function refreshStatus() {
    if (!statusProcess.running) statusProcess.running = true
  }

  function toggle() {
    if (!toggleProcess.running) toggleProcess.running = true
  }

  Process {
    id: toggleProcess
    running: false
    command: ["python3", root.commandPath]
    onExited: root.refreshStatus()
  }

  Process {
    id: statusProcess
    running: false
    command: ["python3", root.commandPath, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.recording = String(text).trim() === "recording"
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.refreshStatus()
  }

  Component.onCompleted: refreshStatus()

  Item {
    id: icon
    anchors.centerIn: parent
    width: 20
    height: 20

    readonly property color iconColor: root.recording && root.bar
      ? root.bar.urgent
      : root.bar ? root.bar.barForeground : "white"
    readonly property string iconFont: root.bar ? root.bar.fontFamily : ""

    Text {
      x: 0
      y: 1
      text: "󰚩"
      color: icon.iconColor
      font.family: icon.iconFont
      font.pixelSize: 14
      renderType: Text.NativeRendering
    }

    Text {
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.rightMargin: 0
      anchors.bottomMargin: 0
      text: "󰍬"
      color: icon.iconColor
      font.family: icon.iconFont
      font.pixelSize: 10
      renderType: Text.NativeRendering
    }
  }

  MouseArea {
    id: clickArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltip)
    onExited: if (root.bar) root.bar.hideTooltip(root)
    onClicked: root.toggle()
  }
}
