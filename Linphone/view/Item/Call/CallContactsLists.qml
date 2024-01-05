import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control
import QtQuick.Effects

import Linphone
import UtilsCpp 1.0

Item {
	id: mainItem
	property int sideMargin: 25 * DefaultStyle.dp
	property int topMargin: 5 * DefaultStyle.dp
	property bool groupCallVisible
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"
	signal callButtonPressed(string address)
	clip: true

	Popup {
		id: startCallPopup
		property FriendGui contact
		onContactChanged: {
			
		}
		underlineColor: DefaultStyle.main1_500_main
		anchors.centerIn: parent
		width: parent.width
		modal: true
		leftPadding: 15 * DefaultStyle.dp
		rightPadding: 15 * DefaultStyle.dp
		topPadding: 20 * DefaultStyle.dp
		bottomPadding: 25 * DefaultStyle.dp
		contentItem: ColumnLayout {
			RowLayout {
				Text {
					text: qsTr("Select channel")
					font {
						pixelSize: 16 * DefaultStyle.dp
						weight: 800 * DefaultStyle.dp
					}
				}
				Item {
					Layout.fillWidth: true
				}
				Button {
					Layout.preferredWidth: 24 * DefaultStyle.dp
					Layout.preferredHeight: 24 * DefaultStyle.dp
					background: Item{}
					contentItem: Image {
						anchors.fill: parent
						source: AppIcons.closeX
					}
					onClicked: startCallPopup.close()
				}
			}
			Repeater {
				id: adresses
				model: [{label: "SIP", address: startCallPopup.contact ? startCallPopup.contact.core.address : ""},
				{label: "Work", address: "06000000000"},
				{label: "Personal", address: "060000000"}
				] //account.adresses
				Button {
					id: channel
					// required property int index
					leftPadding: 0
					rightPadding: 0
					// topPadding: 0
					bottomPadding: 0
					Layout.fillWidth: true
					
					background: Item{}
					contentItem: ColumnLayout {
						RowLayout {
							ColumnLayout {
								Text {
									Layout.leftMargin: 5 * DefaultStyle.dp
									Layout.rightMargin: 5 * DefaultStyle.dp
									text: modelData.label
									font {
										pixelSize: 14 * DefaultStyle.dp
										weight: 700 * DefaultStyle.dp
									}
								}
								Text {
									Layout.leftMargin: 5 * DefaultStyle.dp
									Layout.rightMargin: 5 * DefaultStyle.dp
									text: modelData.address
									font {
										pixelSize: 13 * DefaultStyle.dp
										weight: 400 * DefaultStyle.dp
									}
								}
							}
							Item {
								Layout.fillWidth: true
							}
						}
						Rectangle {
							visible: index < adresses.count - 1
							Layout.fillWidth: true
							Layout.preferredHeight: 1 * DefaultStyle.dp
							color: DefaultStyle.main2_200
						}
					}
					onClicked: mainItem.callButtonPressed(modelData.address)
				}
			}
		}
	}


	Control.ScrollBar {
		id: contactsScrollbar
		active: true
		interactive: true
		policy: Control.ScrollBar.AlwaysOn
		// Layout.fillWidth: true
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		// x: mainItem.x + mainItem.width - width
		// anchors.left: control.right
	}

	Control.Control {
		id: listLayout
		anchors.fill: parent
		anchors.topMargin: mainItem.topMargin
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
				Layout.leftMargin: mainItem.sideMargin
				Layout.rightMargin: mainItem.sideMargin
				color: mainItem.searchBarColor
				borderColor: mainItem.searchBarBorderColor
				placeholderText: qsTr("Rechercher un contact")
				numericPad: numPad
			}
			Control.ScrollView {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.leftMargin: mainItem.sideMargin
				Layout.topMargin: 25 * DefaultStyle.dp
				rightPadding: mainItem.sideMargin
				contentWidth: width - mainItem.sideMargin
				contentHeight: content.height
				clip: true
				Control.ScrollBar.vertical: contactsScrollbar

				ColumnLayout {
					id: content
					width: parent.width
					spacing: 25 * DefaultStyle.dp
					Button {
						visible: mainItem.groupCallVisible
						Layout.fillWidth: true
						leftPadding: 0
						topPadding: 0
						rightPadding: 0
						bottomPadding: 0
						background: Rectangle {
							color: DefaultStyle.groupCallButtonColor
							anchors.fill: parent
							radius: 50 * DefaultStyle.dp
						}
						contentItem: RowLayout {
							Image {
								source: AppIcons.groupCall
								Layout.preferredWidth: 35 * DefaultStyle.dp
								sourceSize.width: 35 * DefaultStyle.dp
								fillMode: Image.PreserveAspectFit
							}
							Text {
								text: "Appel de groupe"
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
							}
						}
					}

					RowLayout {
						visible: searchBar.text.length > 0
						Layout.maximumWidth: parent.width
						Layout.fillWidth: true
						Text {
							text: searchBar.text
							maximumLineCount: 1
							elide: Text.ElideRight
						}
						Item {
							Layout.fillWidth: true
						}
						Control.Button {
							implicitWidth: 30 * DefaultStyle.dp
							implicitHeight: 30 * DefaultStyle.dp
							background: Item {
								visible: false
							}
							contentItem: Image {
								source: AppIcons.phone
								width: 20 * DefaultStyle.dp
								sourceSize.width: 20 * DefaultStyle.dp
								fillMode: Image.PreserveAspectFit
							}
							onClicked: {
								mainItem.callButtonPressed(searchBar.text)
							}
						}
					}
					ColumnLayout {
						Text {
							text: qsTr("All contacts")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						ContactsList{
							Layout.fillWidth: true
							id: contactList
							searchBarText: searchBar.text
						}
					}
					ColumnLayout {
						Text {
							text: qsTr("Suggestions")
							font {
								pixelSize: 16 * DefaultStyle.dp
								weight: 800 * DefaultStyle.dp
							}
						}
						ContactsList{
							contactMenuVisible: false
							Layout.fillHeight: true
							initialHeadersVisible: false
							model: MagicSearchProxy {
								searchText: searchBar.text.length === 0 ? "*" : searchBar.text
								sourceFlags: LinphoneEnums.MagicSearchSource.FavoriteFriends
								aggregationFlag: LinphoneEnums.MagicSearchAggregation.Friend
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

	Item {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		height: numPad.implicitHeight
		NumericPad {
			id: numPad
			width: parent.width
			onLaunchCall: {
				UtilsCpp.createCall(searchBar.text + "@sip.linphone.org")
				// TODO : auto completion instead of sip linphone
			}
		}
	}
}
