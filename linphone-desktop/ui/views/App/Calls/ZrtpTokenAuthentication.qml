import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Utils 1.0

import App.Styles 1.0

Item {
    height: CallStyle.zrtpArea.height
    visible: false
    Layout.fillWidth: true
    anchors.top: container.bottom
    Layout.margins: CallStyle.container.margins

    GridLayout {
        anchors.centerIn: parent
        columns: 1

        Text {
            Layout.fillWidth: true
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Confirm the following SAS with peer:")
            elide: Text.ElideRight
            font.pointSize: CallStyle.zrtpArea.fontSize
            font.bold: true
            color: Colors.j
        }

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: CallStyle.zrtpArea.vu.spacing
            Layout.fillWidth: true

            Text {
                text: qsTr("Say:")
                font.pointSize: CallStyle.zrtpArea.fontSize
                color: Colors.j
            }

            Text {
                text: incall.call.localSAS
                font.pointSize: CallStyle.zrtpArea.fontSize
                font.bold: true
                color: Colors.i
            }

            Text {
                text: "-"
                font.pointSize: CallStyle.zrtpArea.fontSize
                color: Colors.j
            }

            Text {
                text: qsTr("Your correspondent should say:")
                font.pointSize: CallStyle.zrtpArea.fontSize
                color: Colors.j
            }

            Text {
                text: incall.call.remoteSAS
                font.pointSize: CallStyle.zrtpArea.fontSize
                font.bold: true
                color: Colors.i
            }
        }

        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: CallStyle.zrtpArea.vu.spacing
            Layout.fillWidth: true

            TextButtonA {
                text: qsTr('Deny')
                onClicked: {
                    zrtp.visible = false
                    incall.call.verifyAuthenticationToken(false)
                }
            }
            
            TextButtonB {
                text: qsTr('Accept')
                onClicked: {
                    zrtp.visible = false
                    incall.call.verifyAuthenticationToken(true)
                }
            }
        }
    }
}