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

RowLayout {
    id: mainItem
    property ChatGui chat
    property CallGui call
    property alias callHeaderContent: splitPanel.headerContent
    spacing: 0
    MainRightPanel {
        id: splitPanel
        Layout.fillWidth: true
        Layout.fillHeight: true
        panelColor: DefaultStyle.grey_0
        header.visible: !mainItem.call
        clip: true
        headerContent: [
            RowLayout {
                anchors.left: parent?.left
                anchors.leftMargin: mainItem.call ? 0 : Math.round(31 * DefaultStyle.dp)
                anchors.verticalCenter: parent?.verticalCenter
                spacing: Math.round(12 * DefaultStyle.dp)
                Avatar {
                    property var contactObj: mainItem.chat ? UtilsCpp.findFriendByAddress(mainItem.chat?.core.peerAddress) : null
                    contact: contactObj?.value || null
                    displayNameVal: contact ? "" : mainItem.chat.core.avatarUri
                    Layout.preferredWidth: Math.round(45 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(45 * DefaultStyle.dp)
                }
                Text {
                    text: mainItem.chat?.core.title || ""
                    color: DefaultStyle.main2_600
                    Layout.fillWidth: true
                    maximumLineCount: 1
                    font {
                        pixelSize: Typography.h4.pixelSize
                        weight: Math.round(400 * DefaultStyle.dp)
                        capitalization: Font.Capitalize
                    }
                }
            },
            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(41 * DefaultStyle.dp)
                anchors.verticalCenter: parent.verticalCenter
                BigButton {
                    style: ButtonStyle.noBackground
                    icon.source: AppIcons.phone
                }
                BigButton {
                    style: ButtonStyle.noBackground
                    icon.source: AppIcons.videoCamera
                }
                BigButton {
                    style: ButtonStyle.noBackground
                    checkable: true
                    icon.source: AppIcons.info
                    onCheckedChanged: {

                    }
                }
            }
        ]

        content: [
            ChatMessagesListView {
                id: chatMessagesListView
                height: contentHeight
                width: parent.width - anchors.leftMargin - anchors.rightMargin
                chat: mainItem.chat
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: messageSender.top               
                anchors.leftMargin: Math.round(18 * DefaultStyle.dp)
                anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
                anchors.bottomMargin: Math.round(18 * DefaultStyle.dp)
                Control.ScrollBar.vertical: scrollbar
            },
            ScrollBar {
                id: scrollbar
                visible: chatMessagesListView.contentHeight > parent.height
                active: visible
                anchors.top: parent.top
                anchors.bottom: chatMessagesListView.bottom
                anchors.right: parent.right
                anchors.rightMargin: Math.round(5 * DefaultStyle.dp)
                policy: Control.ScrollBar.AsNeeded
            },
            Control.Control {
                id: messageSender
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 79 * DefaultStyle.dp
                leftPadding: Math.round(15 * DefaultStyle.dp)
                rightPadding: Math.round(15 * DefaultStyle.dp)
                topPadding: Math.round(16 * DefaultStyle.dp)
                bottomPadding: Math.round(16 * DefaultStyle.dp)
                background: Rectangle {
                    color: DefaultStyle.grey_100
                }
                contentItem: RowLayout {
                    spacing: Math.round(20 * DefaultStyle.dp)
                    RowLayout {
                        spacing: Math.round(16 * DefaultStyle.dp)
                        BigButton {
                            style: ButtonStyle.noBackground
                            checkable: true
                            icon.source: AppIcons.smiley
                            onCheckedChanged: {
                                console.log("TODO : emoji")
                            }
                        }
                        BigButton {
                            style: ButtonStyle.noBackground
                            icon.source: AppIcons.paperclip
                            onClicked: {
                                console.log("TODO : open explorer to attach file")
                            }
                        }
                        Control.Control {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.round(48 * DefaultStyle.dp)
                            background: Rectangle {
                                id: inputBackground
                                anchors.fill: parent
                                radius: Math.round(30 * DefaultStyle.dp)
                                color: DefaultStyle.grey_0
                            }
                            contentItem: RowLayout {
                                TextArea {
                                    id: sendingTextArea
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width - stackButton.width
                                }
                                StackLayout {
                                    id: stackButton
                                    currentIndex: sendingTextArea.text.length === 0 ? 0 : 1
                                    BigButton {
                                        style: ButtonStyle.noBackground
                                        icon.source: AppIcons.microphone
                                        onClicked: {
                                            console.log("TODO : go to record message")
                                        }
                                    }
                                    BigButton {
                                        style: ButtonStyle.noBackgroundOrange
                                        icon.source: AppIcons.paperPlaneRight
                                        onClicked: {
                                            console.log("TODO : send message")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ]
        
    }
    Rectangle {
        visible: detailsPanel.visible
        color: DefaultStyle.main2_200
        Layout.preferredWidth: Math.round(1 * DefaultStyle.dp)
        Layout.fillHeight: true
    }
    Control.Control {
        id: detailsPanel
        visible: false
        Layout.fillHeight: true
        Layout.preferredWidth: Math.round(387 * DefaultStyle.dp)
        background: Rectangle {
            color: DefaultStyle.grey_0
            anchors.fill: parent
        }
        contentItem: ColumnLayout {

        }
    }
}

