import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone
import UtilsCpp 1.0

ListView {
	id: mainItem
	Layout.preferredHeight: contentHeight
	height: contentHeight
	visible: count > 0

	property string searchBarText

	property bool hoverEnabled: true
	property bool contactMenuVisible: true
	property bool initialHeadersVisible: true

	property FriendGui selectedContact: model.getAt(currentIndex) || null

	onCurrentIndexChanged: selectedContact = model.getAt(currentIndex) || null
	onCountChanged: {
		selectedContact = model.getAt(currentIndex) || null
	}

	signal contactSelected(var contact)
	signal contactStarredChanged()

	onContactStarredChanged: model.forceUpdate()

	model: MagicSearchProxy {
		searchText: searchBarText.length === 0 ? "*" : searchBarText
	}

	delegate: Item {
		id: itemDelegate
		height: 56 * DefaultStyle.dp
		width: mainItem.width
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var previousDisplayName: previousItem ? previousItem.core.displayName : ""
		property var displayName: modelData.core.displayName
		Connections {
			target: modelData.core
			onStarredChanged: mainItem.contactStarredChanged()
		}
		Text {
			id: initial
			anchors.verticalCenter: parent.verticalCenter
			verticalAlignment: Text.AlignVCenter
			Layout.preferredWidth: 20 * DefaultStyle.dp
			opacity: (!previousItem || !previousDisplayName.startsWith(displayName[0])) ? 1 : 0
			text: displayName[0]
			color: DefaultStyle.main2_400
			font {
				pixelSize: 20 * DefaultStyle.dp
				weight: 500 * DefaultStyle.dp
				capitalization: Font.AllUppercase
			}
		}
		RowLayout {
			id: contactDelegate
			anchors.left: initial.right
			anchors.leftMargin: 10 * DefaultStyle.dp
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			z: 1
			Avatar {
				Layout.preferredWidth: 45 * DefaultStyle.dp
				Layout.preferredHeight: 45 * DefaultStyle.dp
				contact: modelData
			}
			Text {
				text: itemDelegate.displayName
				font.pixelSize: 14 * DefaultStyle.dp
				font.capitalization: Font.Capitalize
			}
			Item {
				Layout.fillWidth: true
			}
		}

		PopupButton {
			id: friendPopup
			z: 1
			hoverEnabled: mainItem.hoverEnabled
			visible: mainItem.contactMenuVisible && (contactArea.containsMouse || hovered || popup.opened)
			popup.x: 0
			popup.padding: 10 * DefaultStyle.dp
			anchors.right: parent.right
			anchors.rightMargin: 5 * DefaultStyle.dp
			anchors.verticalCenter: parent.verticalCenter
			popup.contentItem: ColumnLayout {
				Button {
					background: Item{}
					contentItem: RowLayout {
						Image {
							source: modelData.core.starred ? AppIcons.heartFill : AppIcons.heart
							fillMode: Image.PreserveAspectFit
							width: 24 * DefaultStyle.dp
							height: 24 * DefaultStyle.dp
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
						}
						Text {
							text: modelData.core.starred ? qsTr("Enlever des favoris") : qsTr("Mettre en favori")
							color: DefaultStyle.main2_500main
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
					}
					onClicked: {
						modelData.core.lSetStarred(!modelData.core.starred)
						friendPopup.close()
					}
				}
				Button {
					background: Item{}
					contentItem: RowLayout {
						EffectImage {
							source: AppIcons.trashCan
							width: 24 * DefaultStyle.dp
							height: 24 * DefaultStyle.dp
							Layout.preferredWidth: 24 * DefaultStyle.dp
							Layout.preferredHeight: 24 * DefaultStyle.dp
							fillMode: Image.PreserveAspectFit
							colorizationColor: DefaultStyle.danger_500main
						}
						Text {
							text: qsTr("Supprimmer")
							color: DefaultStyle.danger_500main
							font {
								pixelSize: 14 * DefaultStyle.dp
								weight: 400 * DefaultStyle.dp
							}
						}
					}
					onClicked: {
						modelData.core.remove()
						friendPopup.close()
					}
				}
			}
		}
		
		MouseArea {
			id: contactArea
			hoverEnabled: mainItem.hoverEnabled
			anchors.fill: contactDelegate
			height: mainItem.height
			Rectangle {
				anchors.fill: contactArea
				opacity: 0.7
				color: DefaultStyle.main2_100
				visible: contactArea.containsMouse || friendPopup.hovered || mainItem.currentIndex === index
			}
			onClicked: {
				mainItem.currentIndex = index
				mainItem.contactSelected(modelData)
			}
		}
	}
}