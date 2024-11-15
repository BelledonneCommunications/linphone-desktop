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
					//Layout.maximumWidth: mainItem.width
					focus: true
					color: mainItem.searchBarColor
					borderColor: mainItem.searchBarBorderColor
					placeholderText: qsTr("Rechercher un contact")
					numericPadPopup: mainItem.numPadPopup
					KeyNavigation.down: grouCallButton
				}
				ColumnLayout {
					id: content
					spacing: 32 * DefaultStyle.dp
					Button {
						id: grouCallButton
						visible: mainItem.groupCallVisible && !SettingsCpp.disableMeetingsFeature
						Layout.preferredWidth: 320 * DefaultStyle.dp
						Layout.preferredHeight: 44 * DefaultStyle.dp
						padding: 0
						KeyNavigation.up: searchBar
						KeyNavigation.down: contactLoader.item
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
					Loader{
					// This is a hack for an incomprehensible behavior on sections title where they doesn't match with their delegate and can be unordered after resetting models.
						id: contactLoader
						Layout.fillWidth: true
						Layout.fillHeight: true
						property string t: searchBar.text
						onTChanged: {
							contactLoader.active = false
							Qt.callLater(function(){contactLoader.active=true})
						}
						//-------------------------------------------------------------
						sourceComponent: ContactListView{
							id: contactList
							searchBarText: searchBar.text
							onContactClicked: (contact) => {
								mainItem.contactClicked(contact)
							}
						}
					}
				}
			}
		}
	}
}
