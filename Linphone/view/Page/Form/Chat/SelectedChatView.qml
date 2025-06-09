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

    //onEventChanged: {
        // TODO : call when all messages read after scroll to unread feature available
        // if (chat) chat.core.lMarkAsRead()
    //}
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

        content: ColumnLayout {
            spacing: 0
            anchors.fill: parent
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ChatMessagesListView {
                    id: chatMessagesListView
                    clip: true
                    height: contentHeight
                    backgroundColor: splitPanel.panelColor
                    width: parent.width - anchors.leftMargin - anchors.rightMargin
                    chat: mainItem.chat
                    anchors.fill: parent
                    anchors.leftMargin: Math.round(18 * DefaultStyle.dp)
                    anchors.rightMargin: Math.round(18 * DefaultStyle.dp)
                    Control.ScrollBar.vertical: scrollbar

                    Popup {
                        id: emojiPickerPopup
                        y: Math.round(chatMessagesListView.y + chatMessagesListView.height - height - 8*DefaultStyle.dp)
                        x: Math.round(chatMessagesListView.x + 8*DefaultStyle.dp)
                        width: Math.round(393 * DefaultStyle.dp)
                        height: Math.round(291 * DefaultStyle.dp)
                        visible: messageSender.emojiPickerButtonChecked
                        closePolicy: Popup.CloseOnPressOutside
                        onClosed: messageSender.emojiPickerButtonChecked = false
                        padding: 10 * DefaultStyle.dp
                        background: Item {
                            anchors.fill: parent
                            Rectangle {
                                id: buttonBackground
                                anchors.fill: parent
                                color: DefaultStyle.grey_0
                                radius: Math.round(20 * DefaultStyle.dp)
                            }
                            MultiEffect {
                                anchors.fill: buttonBackground
                                source: buttonBackground
                                shadowEnabled: true
                                shadowColor: DefaultStyle.grey_1000
                                shadowBlur: 0.1
                                shadowOpacity: 0.5
                            }
                        }
                        contentItem: EmojiPicker {
                            id: emojiPicker
                            editor: messageSender.textArea
                        }
                    }
                }
                ScrollBar {
                    id: scrollbar
                    visible: chatMessagesListView.contentHeight > parent.height
                    active: visible
                    anchors.top: chatMessagesListView.top
                    anchors.bottom: chatMessagesListView.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(5 * DefaultStyle.dp)
                    policy: Control.ScrollBar.AsNeeded
                }
            }
            Control.Control {
                id: selectedFilesArea
                visible: selectedFiles.count > 0
                Layout.fillWidth: true
                Layout.preferredHeight: Math.round(104 * DefaultStyle.dp)
                topPadding: Math.round(12 * DefaultStyle.dp)
                bottomPadding: Math.round(12 * DefaultStyle.dp)
                leftPadding: Math.round(19 * DefaultStyle.dp)
                rightPadding: Math.round(19 * DefaultStyle.dp)
                
                Button {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: selectedFilesArea.topPadding
                    anchors.rightMargin: selectedFilesArea.rightPadding
                    icon.source: AppIcons.closeX
                    style: ButtonStyle.noBackground
                    onClicked: {
                        contents.clear()
                    }
                }
                background: Item{
                    anchors.fill: parent
                    Rectangle {
                        color: DefaultStyle.grey_0
                        border.color: DefaultStyle.main2_100
                        border.width: Math.round(2 * DefaultStyle.dp)
                        radius: Math.round(20 * DefaultStyle.dp)
                        height: parent.height / 2
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 2 * parent.height / 3
                    }
                }
                contentItem: ListView {
                    id: selectedFiles
                    orientation: ListView.Horizontal
                    spacing: Math.round(16 * DefaultStyle.dp)
                    model: ChatMessageContentProxy {
                        id: contents
			            filterType: ChatMessageContentProxy.FilterContentType.File
                    }
                    delegate: Item {
                        width: Math.round(80 * DefaultStyle.dp)
                        height: Math.round(80 * DefaultStyle.dp)
                        FileView {
                            contentGui: modelData
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            width: Math.round(69 * DefaultStyle.dp)
                            height: Math.round(69 * DefaultStyle.dp)
                        }
                        RoundButton {
                            icon.source: AppIcons.closeX
                            icon.width: Math.round(12 * DefaultStyle.dp)
                            icon.height: Math.round(12 * DefaultStyle.dp)
                            anchors.top: parent.top
                            anchors.right: parent.right
                            style: ButtonStyle.numericPad
                            shadowEnabled: true
                            padding: Math.round(3 * DefaultStyle.dp)
                            onClicked: contents.removeContent(modelData)
                        }
                    }
                    Control.ScrollBar.horizontal: selectedFilesScrollbar
                }
                ScrollBar {
                    id: selectedFilesScrollbar
                    active: true
                    anchors.bottom: selectedFilesArea.bottom
                    anchors.left: selectedFilesArea.left
                    anchors.right: selectedFilesArea.right
                }
            }
            ChatDroppableTextArea {
                id: messageSender
				visible: !mainItem.chat.core.isReadOnly
                Layout.fillWidth: true
                Layout.preferredHeight: height
                Component.onCompleted: {
                    if (mainItem.chat) text = mainItem.chat.core.sendingText
                }
                onTextChanged: {
                    if (text !== "" && mainItem.chat.core.composingName !== "") {
                        mainItem.chat.core.lCompose()
                    }
                    mainItem.chat.core.sendingText = text
                }
                onSendText: {
                    var filesContents = contents.getAll()
                    if (filesContents.length === 0)
                        mainItem.chat.core.lSendTextMessage(text)
                    else mainItem.chat.core.lSendMessage(text, filesContents)
                    messageSender.textArea.clear()
                    contents.clear()
                }
                onDropped: (files) => {
                    contents.addFiles(files)
                }
            }
        }
        
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

		contentItem: Loader {
			id: contentLoader
			anchors.top: parent.top
			anchors.topMargin: Math.round(39 * DefaultStyle.dp)
			active: true
			property var chat: mainItem.chat
			sourceComponent: chat && chat.core.isGroupChat ? groupInfoComponent : oneToOneInfoComponent

			onLoaded: {
				if (item && item.hasOwnProperty("chat")) {
					item.chat = chat
				}
			}
		}

		Component {
			id: oneToOneInfoComponent
			OneOneConversationInfos {
				chat: contentLoader.chat
			}
		}

		Component {
			id: groupInfoComponent
			GroupConversationInfos {
				chat: contentLoader.chat
			}
		}
	}
}

