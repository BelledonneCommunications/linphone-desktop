import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control

import Linphone
import UtilsCpp

Item {
	id: mainItem
	width: 517 * DefaultStyle.dp
	readonly property int topPadding: 23 * DefaultStyle.dp
	readonly property int bottomPadding: 18 * DefaultStyle.dp
	readonly property int leftPadding: 32 * DefaultStyle.dp
	readonly property int rightPadding: 32 * DefaultStyle.dp
	readonly property int spacing: 16 * DefaultStyle.dp
	implicitHeight: list.contentHeight + topPadding + bottomPadding + 32 * DefaultStyle.dp + 1 + newAccountArea.height
	ColumnLayout{
		anchors.top: parent.top
		anchors.topMargin: mainItem.topPadding
		anchors.left: parent.left
		anchors.leftMargin: mainItem.leftPadding
		anchors.right: parent.right
		anchors.rightMargin: mainItem.rightPadding
		ListView{
			id: list
			Layout.preferredHeight: contentHeight
			Layout.fillWidth: true
			spacing: mainItem.spacing
			model: AccountProxy{}
			delegate: Contact{
				width: list.width
				account: modelData
			}
		}
		Rectangle{
			id: separator
			Layout.fillWidth: true
			Layout.topMargin: mainItem.spacing
			Layout.bottomMargin: mainItem.spacing
			height: 1
			color: DefaultStyle.main2_300
		}
		MouseArea{ // TODO
			Layout.fillWidth: true
			Layout.preferredHeight: 32 * DefaultStyle.dp
			onClicked: console.log('New!')
			RowLayout{
				id: newAccountArea
				anchors.fill: parent
				spacing: 5 * DefaultStyle.dp
				EffectImage {
					id: newAccount
					image.source: AppIcons.plusCircle
					Layout.fillHeight: true
					Layout.preferredWidth: height
					Layout.alignment: Qt.AlignHCenter
					image.fillMode: Image.PreserveAspectFit
					colorizationColor: DefaultStyle.main2_500main
				}
				Text{
					Layout.fillHeight: true
					Layout.fillWidth: true
					verticalAlignment: Text.AlignVCenter
					font.weight: 400 * DefaultStyle.dp
					font.pixelSize: 14 * DefaultStyle.dp
					color: DefaultStyle.main2_500main
					text: 'Ajouter un compte'
				}
			}
		}
	}
}
 
