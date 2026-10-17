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
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {

    property var title: String
    property var entries

    Text {
        Accessible.role: Accessible.Heading
        Accessible.name: text
        font: Typography.h4
        color: DefaultStyle.main2_600
        text: title
        Layout.topMargin: Utils.getSizeWithScreenRatio(5)
    }

    Control.Control {
        Layout.fillWidth: true
        Layout.preferredHeight: implicitHeight
        Layout.topMargin: Utils.getSizeWithScreenRatio(9)
        background: Rectangle {
            anchors.fill: parent
            color: DefaultStyle.grey_100
            radius: Utils.getSizeWithScreenRatio(15)
        }

        contentItem: ColumnLayout {
            id: contentColumn
            spacing: 0

            Repeater {
                model: entries

                delegate: ColumnLayout {
                    width: parent.width
                    spacing: 0
					property bool hovered: false

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? Utils.getSizeWithScreenRatio(56) : 0
                        visible: modelData.visible

                        RowLayout {
                            anchors.fill: parent
                            spacing: Utils.getSizeWithScreenRatio(8)
                            anchors.leftMargin: Utils.getSizeWithScreenRatio(17)
                            anchors.rightMargin: Utils.getSizeWithScreenRatio(10)

                            EffectImage {
                                fillMode: Image.PreserveAspectFit
                                imageSource: modelData.icon
                                colorizationColor: modelData.color
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                            }

                            Text {
                                text: modelData.text
                                font: hovered || entryArea.activeFocus ? Typography.p1b : Typography.p1
                                color: modelData.color
                                Layout.alignment: Qt.AlignVCenter
                                Layout.fillWidth: true
                            }

                            EffectImage {
                                visible: modelData.showRightArrow
                                fillMode: Image.PreserveAspectFit
                                imageSource: AppIcons.rightArrow
                                colorizationColor: modelData.color
                                Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
                                Layout.preferredWidth: Utils.getSizeWithScreenRatio(20)
                            }
                        }

                        MouseArea {
                            id: entryArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            activeFocusOnTab: true
                            Accessible.role: Accessible.Button
                            Accessible.name: modelData.text
                            Accessible.onPressAction: modelData.action()
                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Space || event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    modelData.action()
                                    event.accepted = true
                                }
                            }
                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                radius: Utils.getSizeWithScreenRatio(10)
                                border.color: DefaultStyle.main2_900
                                border.width: Utils.getSizeWithScreenRatio(3)
                                visible: entryArea.activeFocus
                            }
                            onClicked: modelData.action()
							onEntered: hovered = true
							onExited: hovered = false
							hoverEnabled: true
                        }
                    }

                    Rectangle {
                        visible: index < entries.length - 1
                        color: DefaultStyle.main2_200
                        height: Utils.getSizeWithScreenRatio(1)
                        width: parent.width - Utils.getSizeWithScreenRatio(30)
                        Layout.leftMargin: Utils.getSizeWithScreenRatio(17)
                    }
                }
            }
        }
    }
}
