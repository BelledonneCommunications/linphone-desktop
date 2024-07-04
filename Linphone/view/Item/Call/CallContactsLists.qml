import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp

Item {
	id: mainItem
	property bool groupCallVisible
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"
	property alias searchBar: searchBar
	signal callButtonPressed(string address)
	signal groupCallCreationRequested()
	property FriendGui selectedContact
	property NumericPad numPad
	clip: true

	Control.Control {
		id: listLayout
		anchors.fill: parent
		background: Item {
			anchors.fill: parent
		}
		contentItem: ColumnLayout {
			anchors.fill: parent
			spacing: 10 * DefaultStyle.dp
			SearchBar {
				id: searchBar
				Layout.alignment: Qt.AlignTop
				Layout.fillWidth: true
				Layout.maximumWidth: mainItem.width
				color: mainItem.searchBarColor
				borderColor: mainItem.searchBarBorderColor
				placeholderText: qsTr("Rechercher un contact")
				numericPad: mainItem.numPad
			}
			Control.ScrollView {
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
					width: parent.width
					spacing: 32 * DefaultStyle.dp
					Button {
						visible: mainItem.groupCallVisible && !SettingsCpp.disableMeetingsFeature
						Layout.preferredWidth: 320 * DefaultStyle.dp
						padding: 0
						background: Rectangle {
							gradient: Gradient {
								orientation: Gradient.Horizontal
								GradientStop { position: 0.0; color: DefaultStyle.main2_100}
								GradientStop { position: 1.0; color: DefaultStyle.grey_0}
							}
							anchors.fill: parent
							radius: 50 * DefaultStyle.dp
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
						onClicked: mainItem.groupCallCreationRequested()
					}
					ColumnLayout {
						spacing: 18 * DefaultStyle.dp
						Layout.rightMargin: 39 * DefaultStyle.dp
						Text {
							text: qsTr("All contacts")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						ContactsList{
							id: contactList
							Layout.fillWidth: true
							Layout.preferredHeight: contentHeight
							Control.ScrollBar.vertical.visible: false
							contactMenuVisible: false
							model: MagicSearchProxy {
								searchText: searchBar.text.length === 0 ? "*" : searchBar.text
							}
							onSelectedContactChanged: mainItem.selectedContact = selectedContact
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
						ContactsList{
							contactMenuVisible: false
							Layout.fillWidth: true
							Layout.fillHeight: true
							Control.ScrollBar.vertical.visible: false
							Layout.preferredHeight: contentHeight
							initialHeadersVisible: false
							displayNameCapitalization: false
							model: MagicSearchProxy {
								searchText: searchBar.text.length === 0 ? "*" : searchBar.text
								sourceFlags: LinphoneEnums.MagicSearchSource.All
								aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
							}
							onSelectedContactChanged: mainItem.selectedContact = selectedContact
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
