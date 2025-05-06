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

    onChatChanged: {
        // TODO : call when all messages read after scroll to unread feature available
        if (chat) chat.core.lMarkAsRead()
    }
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
                    checkedImageColor: DefaultStyle.main1_500_main
                    icon.source: AppIcons.info
                    onCheckedChanged: {
                        detailsPanel.visible = !detailsPanel.visible
                    }
                }
            }
        ]

        content: [
            ChatMessagesListView {
                id: chatMessagesListView
                height: contentHeight
                backgroundColor: panelColor
                width: parent.width - anchors.leftMargin - anchors.rightMargin
                chat: mainItem.chat
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: messageSender.top               
                anchors.leftMargin: Math.round(18 * DefaultStyle.dp)
                anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
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
                leftPadding: Math.round(15 * DefaultStyle.dp)
                rightPadding: Math.round(15 * DefaultStyle.dp)
                topPadding: Math.round(24 * DefaultStyle.dp)
                bottomPadding: Math.round(16 * DefaultStyle.dp)
                background: Rectangle {
                    anchors.fill: parent
                    color: DefaultStyle.grey_100
                    MediumButton {
                        id: expandButton
                        anchors.top: parent.top
                        anchors.topMargin: Math.round(4 * DefaultStyle.dp)
                        anchors.horizontalCenter: parent.horizontalCenter
                        style: ButtonStyle.noBackgroundOrange
                        icon.source: checked ? AppIcons.downArrow : AppIcons.upArrow
                        checkable: true
                    }
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
                            leftPadding: Math.round(15 * DefaultStyle.dp)
                            rightPadding: Math.round(15 * DefaultStyle.dp)
                            topPadding: Math.round(16 * DefaultStyle.dp)
                            bottomPadding: Math.round(16 * DefaultStyle.dp)
                            background: Rectangle {
                                id: inputBackground
                                anchors.fill: parent
                                radius: Math.round(35 * DefaultStyle.dp)
                                color: DefaultStyle.grey_0
                            }
                            contentItem: RowLayout {
                                Flickable {
                                    id: sendingAreaFlickable
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: parent.width - stackButton.width
                                    Layout.preferredHeight: Math.min(Math.round(60 * DefaultStyle.dp), contentHeight)
                                    Binding {
                                        target: sendingAreaFlickable
                                        when: expandButton.checked
                                        property: "Layout.preferredHeight"
                                        value: Math.round(250 * DefaultStyle.dp)
                                        restoreMode: Binding.RestoreBindingOrValue
                                    }
                                    Layout.fillHeight: true
                                    contentHeight: sendingTextArea.contentHeight
                                    contentWidth: width

                                    function ensureVisible(r) {
                                        if (contentX >= r.x)
                                            contentX = r.x;
                                        else if (contentX+width <= r.x+r.width)
                                            contentX = r.x+r.width-width;
                                        if (contentY >= r.y)
                                            contentY = r.y;
                                        else if (contentY+height <= r.y+r.height)
                                            contentY = r.y+r.height-height;
                                    }

                                    TextArea {
                                        id: sendingTextArea
                                        width: parent.width
                                        height: sendingAreaFlickable.height
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        //: Say something… : placeholder text for sending message text area
                                        placeholderText: qsTr("Dites quelque chose…")
                                        placeholderTextColor: DefaultStyle.main2_400
                                        onCursorRectangleChanged: sendingAreaFlickable.ensureVisible(cursorRectangle)
                                        property string previousText
                                        Component.onCompleted: previousText = text
                                        onTextChanged: {
                                            if (previousText === "" && text !== "") {
                                                mainItem.chat.core.lCompose()
                                            }
                                        }
                                    }
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
                                            mainItem.chat.core.lSendTextMessage(sendingTextArea.text)
                                            sendingTextArea.clear()
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
        contentItem: CallHistoryLayout {
            chatGui: mainItem.chat
            detailContent: ColumnLayout {
                DetailLayout {
                    //: Other actions
                    label: qsTr("Autres actions")
                    content: ColumnLayout {
                        // IconLabelButton {
                        //     Layout.fillWidth: true
                        //     Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                        //     icon.source: AppIcons.signOut
                        //     //: "Quitter la conversation"
                        //     text: qsTr("Quitter la conversation")
                        //     onClicked: {

                        //     }
                        //     style: ButtonStyle.noBackground
                        // }
                        IconLabelButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.round(50 * DefaultStyle.dp)
                            icon.source: AppIcons.trashCan
                            //: "Supprimer l'historique"
                            text: qsTr("Supprimer l'historique")
                            onClicked: {
                                mainWindow.showConfirmationLambdaPopup(qsTr("Supprimer l'historique ?"),
                                qsTr("Tous les messages seront supprimés de la chatroom.Souhaitez-vous continuer ?"),
                                "",
                                function(confirmed) {
                                    if (confirmed) {
                                        mainItem.chat.core.lDeleteHistory()
                                    }
                                })
                            }
                            style: ButtonStyle.noBackgroundRed
                        }
                    }
                }
                Item {Layout.fillHeight: true}
            }
        }
    }
}

