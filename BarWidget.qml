import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "shusui.flow-dictation"

  readonly property string home: Quickshell.env("HOME") || ""
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || home + "/.config"
  readonly property string commandPath: configHome + "/omarchy/plugins/" + moduleName + "/flow_dictation.py"
  property bool recording: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

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

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    active: root.recording
    useActiveColor: true
    tooltipText: root.recording
      ? "Flow Dictation is recording — click to stop and insert text"
      : "Flow Dictation — click to start recording"
    iconComponent: Component {
      Item {
        Text {
          x: 0
          y: 2
          text: "󰚩"
          color: button.active && button.useActiveColor ? button.activeColor : button.foreground
          font.family: button.fontFamily
          font.pixelSize: 14
          renderType: Text.NativeRendering
        }
        Text {
          anchors.right: parent.right
          anchors.bottom: parent.bottom
          anchors.rightMargin: 0
          anchors.bottomMargin: 1
          text: "󰍬"
          color: button.active && button.useActiveColor ? button.activeColor : button.foreground
          font.family: button.fontFamily
          font.pixelSize: 10
          renderType: Text.NativeRendering
        }
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.toggle()
    }
  }
}
