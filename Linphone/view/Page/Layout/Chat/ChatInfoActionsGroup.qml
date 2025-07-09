import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {

    property var title: String
    property var entries

    Text {
        font: Typography.h4
        color: DefaultStyle.main2_600
        text: title
        Layout.topMargin: Math.round(5 * DefaultStyle.dp)
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Math.round(9 * DefaultStyle.dp)
        color: DefaultStyle.grey_100
        radius: Math.round(15 * DefaultStyle.dp)
        height: contentColumn.implicitHeight

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: entries

                delegate: ColumnLayout {
                    width: parent.width
                    spacing: 0
					property bool hovered: false

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? Math.round(56 * DefaultStyle.dp) : 0
                        visible: modelData.visible

                        RowLayout {
                            anchors.fill: parent
                            spacing: Math.round(8 * DefaultStyle.dp)
                            anchors.leftMargin: Math.round(17 * DefaultStyle.dp)
                            anchors.rightMargin: Math.round(10 * DefaultStyle.dp)

                            EffectImage {
                                fillMode: Image.PreserveAspectFit
                                imageSource: modelData.icon
                                colorizationColor: modelData.color
                                Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
                                Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                            }

                            Text {
                                text: modelData.text
                                font: hovered ? Typography.p1b : Typography.p1
                                color: modelData.color
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: true
                            }

                            EffectImage {
                                visible: modelData.showRightArrow
                                fillMode: Image.PreserveAspectFit
                                imageSource: AppIcons.rightArrow
                                colorizationColor: modelData.color
                                Layout.preferredHeight: Math.round(20 * DefaultStyle.dp)
                                Layout.preferredWidth: Math.round(20 * DefaultStyle.dp)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.action()
							onEntered: hovered = true
							onExited: hovered = false
							hoverEnabled: true
                        }
                    }

                    Rectangle {
                        visible: index < entries.length - 1
                        color: DefaultStyle.main2_200
                        height: Math.round(1 * DefaultStyle.dp)
                        width: parent.width - Math.round(30 * DefaultStyle.dp)
                        Layout.leftMargin: Math.round(17 * DefaultStyle.dp)
                    }
                }
            }
        }
    }
}
