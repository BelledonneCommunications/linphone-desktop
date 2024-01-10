import QtQuick 2.7
import QtQuick.Layouts 1.3

import Linphone
import UtilsCpp 1.0

ListView {
	id: mainItem
	Layout.fillWidth: true
	Layout.preferredHeight: contentHeight
	height: contentHeight
	visible: count > 0

	property string searchBarText

	property bool contactMenuVisible: true
	property bool initialHeadersVisible: true

	signal contactSelected(var contact)

	model: MagicSearchProxy {
		searchText: searchBarText.length === 0 ? "*" : searchBarText
	}

	delegate: RowLayout {
		id: itemDelegate
		property var previousItem : mainItem.model.count > 0 && index > 0 ? mainItem.model.getAt(index-1) : null
		property var previousDisplayName: previousItem ? UtilsCpp.getDisplayName(previousItem.core.address) : null
		property string previousDisplayNameText: previousDisplayName ? previousDisplayName.value : ""
		property var displayName: UtilsCpp.getDisplayName(modelData.core.address)
		property string displayNameText: displayName ? displayName.value : ""
		Text {
			Layout.preferredWidth: 20 * DefaultStyle.dp
			opacity: (!previousItem || !previousDisplayNameText.startsWith(displayNameText[0])) ? 1 : 0
			text: displayNameText[0]
			color: DefaultStyle.main2_400
			font {
				pixelSize: 20 * DefaultStyle.dp
				weight: 500 * DefaultStyle.dp
				capitalization: Font.AllUppercase
			}
		}
		Item {
			width: mainItem.width
			Layout.preferredWidth: mainItem.width
			height: 56 * DefaultStyle.dp
			RowLayout {
				anchors.fill: parent
				z: 1
				Avatar {
					Layout.preferredWidth: 45 * DefaultStyle.dp
					Layout.preferredHeight: 45 * DefaultStyle.dp
					contact: modelData
				}
				Text {
					text: itemDelegate.displayNameText
					font.pixelSize: 14 * DefaultStyle.dp
					font.capitalization: Font.Capitalize
				}
				Item {
					Layout.fillWidth: true
				}
				PopupButton {
					id: friendPopup
					hoverEnabled: true
					visible: mainItem.contactMenuVisible && (contactArea.containsMouse || hovered || popup.opened)
					popup.x: 0
					popup.padding: 10 * DefaultStyle.dp
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
			}
			MouseArea {
				id: contactArea
				hoverEnabled: true
				anchors.fill: parent
				Rectangle {
					anchors.fill: contactArea
					opacity: 0.1
					color: DefaultStyle.main2_500main
					visible: contactArea.containsMouse || friendPopup.hovered
				}
				onClicked: {
					mainItem.contactSelected(modelData)
				}
			}
		}
	}
}