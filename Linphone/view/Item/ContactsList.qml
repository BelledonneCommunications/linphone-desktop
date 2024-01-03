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

	property string initialProxyModel

	property bool favorite: true
	// Component.onCompleted: model.sourceModel.sourceFlags = magicSearchSourceFlags

	property string searchBarText

	property bool contactMenuVisible: true

	model: FriendInitialProxy {
		filterText: initialProxyModel
		property int sourceFlags: LinphoneEnums.MagicSearchSource.FavoriteFriends//mainItem.magicSearchSourceFlags
		sourceModel: MagicSearchProxy {
			id: search
			searchText: searchBarText.length === 0 ? "*" : searchBarText
		}
	}
	delegate: Item {
		width: mainItem.width
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
				text: UtilsCpp.getDisplayName(modelData.core.address).value
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
								image.source: AppIcons.trashCan
								width: 24 * DefaultStyle.dp
								height: 24 * DefaultStyle.dp
								Layout.preferredWidth: 24 * DefaultStyle.dp
								Layout.preferredHeight: 24 * DefaultStyle.dp
								image.fillMode: Image.PreserveAspectFit
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
				startCallPopup.contact = modelData
				startCallPopup.open()
				// mainItem.callButtonPressed(modelData.core.address)
			}
		}
	}
}