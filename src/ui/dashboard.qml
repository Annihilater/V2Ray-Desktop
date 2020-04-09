import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import com.v2ray.desktop.AppProxy 2.1

ColumnLayout {
    id: layoutDashboard
    anchors.fill: parent
    anchors.margins: 10
    spacing: 20

    RowLayout {
        Image {
            source: "qrc:///images/icon-dashboard.svg"
            sourceSize.width: 40
            sourceSize.height: 40
            mipmap: true
        }

        Text {
            text: qsTr("Dashboard")
            color: "white"
            font.pointSize: Qt.platform.os == "windows" ? 20 : 24
        }
    }

    GridLayout {
        columns: 2
        flow: GridLayout.LeftToRight
        rowSpacing: 20
        columnSpacing: 20

        Label {
            text: qsTr("Network Status")
            color: "white"
            font.bold: true
            Layout.alignment: Qt.AlignTop
        }

        Label {
            id: labelNetworkStatus
            text: qsTr("N/a")
            color: "white"
        }

        Label {
            text: qsTr("Proxy Settings")
            color: "white"
            font.bold: true
            Layout.alignment: Qt.AlignTop
        }

        Label {
            id: labelProxySettings
            text: qsTr("N/a")
            color: "white"
        }

        Label {
            text: qsTr("Operating System")
            color: "white"
            font.bold: true
        }

        Label {
            id: labelOperatingSystem
            text: qsTr("N/a")
            color: "white"
        }

        Label {
            text: qsTr("V2Ray Desktop Version")
            color: "white"
            font.bold: true
        }

        Label {
            id: labelAppVersion
            text: qsTr("N/a")
            color: "white"
        }

        Label {
            text: qsTr("Clash Version")
            color: "white"
            font.bold: true
        }

        Label {
            id: labelV2rayVersion
            text: qsTr("N/a")
            color: "white"
        }
    }

    Item {      // spacer item
        Layout.fillWidth: true
        Layout.fillHeight: true
        Rectangle {
            anchors.fill: parent
            color: "transparent"
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: function() {
            if (appWindow.visible) {
                AppProxy.getNetworkStatus()
                AppProxy.getProxySettings()
            }
        }
    }

    Connections {
        target: AppProxy

        onAppVersionReady: function(appVersion) {
            labelAppVersion.text = appVersion
        }

        onV2RayCoreVersionReady: function(v2RayVersion) {
            labelV2rayVersion.text = v2RayVersion
        }

        onOperatingSystemReady: function(operatingSystem) {
            labelOperatingSystem.text = operatingSystem
        }

        onNetworkStatusReady: function(networkStatus) {
            networkStatus = JSON.parse(networkStatus)
            if (networkStatus["isGoogleAccessible"]) {
                labelNetworkStatus.text = qsTr("Everything works fine.\nYou can access the free Internet.")
            } else if (networkStatus["isBaiduAccessible"]) {
                labelNetworkStatus.text = qsTr("Please check your proxy settings.")
            } else {
                labelNetworkStatus.text = qsTr("You're offline.\nPlease check the network connection.")
            }
        }

        onProxySettingsReady: function(proxySettings) {
            proxySettings = JSON.parse(proxySettings)
            var pSettings = "";
            pSettings += qsTr("System Proxy: ") + proxySettings["systemProxy"] + "\n"
            pSettings += qsTr("Clash: ") + (proxySettings["isV2RayRunning"] ? qsTr("Running") : qsTr("Not running")) + "\n"
            pSettings += qsTr("Proxy Mode: ") + proxySettings["proxyMode"] + "\n"
            if (proxySettings["isV2RayRunning"]) {
                if (proxySettings["connectedServers"].length === 0) {
                    pSettings += qsTr("No servers connected.\n")
                    pSettings += qsTr("Please select servers to connect at servers page.\n")
                } else {
                    pSettings += qsTr("Connected Servers: \n")
                    for (var i = 0; i < proxySettings["connectedServers"].length; ++ i) {
                      pSettings += "- " + proxySettings["connectedServers"][i] + "\n"
                    }
                }
            }
            labelProxySettings.text = pSettings
        }
    }

    Component.onCompleted: function() {
        AppProxy.getAppVersion()
        AppProxy.getOperatingSystem()
        AppProxy.getV2RayCoreVersion()
        AppProxy.getNetworkStatus()
        AppProxy.getProxySettings()
    }
}
