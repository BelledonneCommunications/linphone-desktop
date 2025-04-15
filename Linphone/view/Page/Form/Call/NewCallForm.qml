import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp

FocusScope {
	id: mainItem
	property bool groupCallVisible
	property bool displayCurrentCalls: false
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"
	property alias searchBar: searchBar
	property NumericPadPopup numPadPopup
	signal callButtonPressed(string address)
	signal groupCallCreationRequested()
	signal transferCallToAnotherRequested(CallGui dest)
	signal contactClicked(FriendGui contact)
	clip: true

	ColumnLayout {
		anchors.fill: parent
        spacing: Math.round(22 * DefaultStyle.dp)
		ColumnLayout {
            spacing: Math.round(18 * DefaultStyle.dp)
            visible: mainItem.displayCurrentCalls && callList.count > 0
			Text {
                //: "Appels en cours"
                text: qsTr("call_transfer_active_calls_label")
				font {
                    pixelSize: Typography.h4.pixelSize
                    weight: Typography.h4.weight
				}
			}
			Flickable {
				Layout.fillWidth: true
                Layout.preferredHeight: callListBackground.height
				Layout.maximumHeight: mainItem.height/2
                contentHeight: callListBackground.height
				contentWidth: width
				RoundedPane {
                    id: callListBackground
					anchors.left: parent.left
					anchors.right: parent.right
					contentItem: CallListView {
                        id: callList
						isTransferList: true
						onTransferCallToAnotherRequested: (dest) => {
							mainItem.transferCallToAnotherRequested(dest)
						}
					}
				}
			}
		}

        ColumnLayout {
            onVisibleChanged: if (!visible) mainItem.numPadPopup.close()
            spacing: Math.round(38 * DefaultStyle.dp)
            SearchBar {
                id: searchBar
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.rightMargin: Math.round(39 * DefaultStyle.dp)
                focus: true
                color: mainItem.searchBarColor
                borderColor: mainItem.searchBarBorderColor
                //: "Rechercher un contact"
                placeholderText: qsTr("search_bar_look_for_contact_text")
                numericPadPopup: mainItem.numPadPopup
                KeyNavigation.down: grouCallButton
            }
            ColumnLayout {
                id: content
                spacing: Math.round(32 * DefaultStyle.dp)
                Button {
                    id: grouCallButton
                    visible: mainItem.groupCallVisible && !SettingsCpp.disableMeetingsFeature
                    Layout.preferredWidth: Math.round(320 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(44 * DefaultStyle.dp)
                    padding: 0
                    KeyNavigation.up: searchBar
                    KeyNavigation.down: contactList
                    onClicked: mainItem.groupCallCreationRequested()
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Math.round(50 * DefaultStyle.dp)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: DefaultStyle.main2_100}
                            GradientStop { position: 1.0; color: DefaultStyle.grey_0}
                        }
                    }
                    contentItem: RowLayout {
                        spacing: Math.round(16 * DefaultStyle.dp)
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            source: AppIcons.groupCall
                            Layout.preferredWidth: Math.round(44 * DefaultStyle.dp)
                            sourceSize.width: Math.round(44 * DefaultStyle.dp)
                            fillMode: Image.PreserveAspectFit
                        }
                        Text {
                            text: qsTr("call_start_group_call_title")
                            color: DefaultStyle.grey_1000
                            font {
                                pixelSize: Typography.h4.pixelSize
                                weight: Typography.h4.weight
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        EffectImage {
                            imageSource: AppIcons.rightArrow
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                            colorizationColor: DefaultStyle.main2_500main
                        }
                    }
                }
                AllContactListView{
                    id: contactList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    showContactMenu: false
                    searchBarText: searchBar.text
                    onContactSelected: (contact) => {
                        mainItem.contactClicked(contact)
                    }
                }
            }
        }
    }
}
