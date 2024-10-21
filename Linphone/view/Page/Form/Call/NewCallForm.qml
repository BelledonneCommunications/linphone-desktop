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
		spacing: 22 * DefaultStyle.dp
		ColumnLayout {
			spacing: 18 * DefaultStyle.dp
			visible: mainItem.displayCurrentCalls
			Text {
				text: qsTr("Appels en cours")
				font {
					pixelSize: 16 * DefaultStyle.dp
					weight: 800 * DefaultStyle.dp
				}
			}
			Flickable {
				Layout.fillWidth: true
				Layout.preferredHeight: callList.height
				Layout.maximumHeight: mainItem.height/2
				// Layout.fillHeight: true
				contentHeight: callList.height
				contentWidth: width
				RoundedPane {
					id: callList
					anchors.left: parent.left
					anchors.right: parent.right
					contentItem: CallListView {
						isTransferList: true
						onTransferCallToAnotherRequested: (dest) => {
							mainItem.transferCallToAnotherRequested(dest)
						}
					}
				}
			}
		}

		Control.Control {
			id: listLayout
			Layout.fillWidth: true
			Layout.fillHeight: true
			background: Item {
				anchors.fill: parent
			}
			contentItem: ColumnLayout {
				// anchors.fill: parent
				spacing: 10 * DefaultStyle.dp
				SearchBar {
					id: searchBar
					Layout.alignment: Qt.AlignTop
					Layout.fillWidth: true
					Layout.rightMargin: 39 * DefaultStyle.dp
					Layout.maximumWidth: mainItem.width
					focus: true
					color: mainItem.searchBarColor
					borderColor: mainItem.searchBarBorderColor
					placeholderText: qsTr("Rechercher un contact")
					numericPadPopup: mainItem.numPadPopup
					KeyNavigation.down: grouCallButton
				}
				Flickable {
					Layout.fillWidth: true
					Layout.fillHeight: true
					Layout.topMargin: 25 * DefaultStyle.dp
					contentWidth: width
					contentHeight: content.height
					clip: true
					Control.ScrollBar.vertical: ScrollBar {
						active: true
						interactive: true
						policy: Control.ScrollBar.AsNeeded
						anchors.top: parent.top
						anchors.bottom: parent.bottom
						anchors.right: parent.right
						anchors.rightMargin: 8 * DefaultStyle.dp
					}

					ColumnLayout {
						id: content
						spacing: 32 * DefaultStyle.dp
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.rightMargin: 39 * DefaultStyle.dp
						Button {
							id: grouCallButton
							visible: mainItem.groupCallVisible && !SettingsCpp.disableMeetingsFeature
							Layout.preferredWidth: 320 * DefaultStyle.dp
							Layout.preferredHeight: 44 * DefaultStyle.dp
							padding: 0
							KeyNavigation.up: searchBar
							KeyNavigation.down: contactList.count >0 ? contactList : searchList
							onClicked: mainItem.groupCallCreationRequested()
							background: Rectangle {
								anchors.fill: parent
								radius: 50 * DefaultStyle.dp
								gradient: Gradient {
									orientation: Gradient.Horizontal
									GradientStop { position: 0.0; color: DefaultStyle.main2_100}
									GradientStop { position: 1.0; color: DefaultStyle.grey_0}
								}
							}
							contentItem: RowLayout {
								spacing: 16 * DefaultStyle.dp
								anchors.verticalCenter: parent.verticalCenter
								Image {
									source: AppIcons.groupCall
									Layout.preferredWidth: 44 * DefaultStyle.dp
									sourceSize.width: 44 * DefaultStyle.dp
									fillMode: Image.PreserveAspectFit
								}
								Text {
									text: "Appel de groupe"
									color: DefaultStyle.grey_1000
									font {
										pixelSize: 16 * DefaultStyle.dp
										weight: 800 * DefaultStyle.dp
										underline: grouCallButton.shadowEnabled
									}
								}
								Item {
									Layout.fillWidth: true
								}
								Image {
									source: AppIcons.rightArrow
									Layout.preferredWidth: 24 * DefaultStyle.dp
									Layout.preferredHeight: 24 * DefaultStyle.dp
								}
							}
						}
						ColumnLayout {
							visible: contactList.contentHeight > 0
							spacing: 18 * DefaultStyle.dp
							Text {
								text: qsTr("Contacts")
								font {
									pixelSize: 16 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
							}
							ContactListView{
								id: contactList
								Layout.fillWidth: true
								Layout.preferredHeight: contentHeight
								Control.ScrollBar.vertical.visible: false
								contactMenuVisible: false
								searchBarText: searchBar.text
								onContactClicked: (contact) => {
									mainItem.contactClicked(contact)
								}
							}
						}
						ColumnLayout {
							spacing: 18 * DefaultStyle.dp
							Text {
								text: qsTr("Suggestions")
								font {
									pixelSize: 16 * DefaultStyle.dp
									weight: 800 * DefaultStyle.dp
								}
							}
							ContactListView{
								id: searchList
								contactMenuVisible: false
								Layout.fillWidth: true
								Layout.fillHeight: true
								Control.ScrollBar.vertical.visible: false
								Layout.preferredHeight: contentHeight
								initialHeadersVisible: false
								displayNameCapitalization: false
								searchBarText: searchBar.text
								sourceFlags: LinphoneEnums.MagicSearchSource.All
								onContactClicked: (contact) => {
									mainItem.contactClicked(contact)
								}
							}
						}
						Item {
							Layout.fillHeight: true
						}
					}
				}
			}
		}
	}
}
