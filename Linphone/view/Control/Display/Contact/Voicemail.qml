import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import Linphone
import UtilsCpp
import SettingsCpp

Rectangle{
	id: mainItem
	property int voicemailCount: 0
	visible: voicemailCount > 0
	width: 27 * DefaultStyle.dp
	height: 28 * DefaultStyle.dp
	signal clicked()
	Button {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		icon.source: AppIcons.voicemail
		width: 24 * DefaultStyle.dp
		height: 24 * DefaultStyle.dp
		background: Item {
			anchors.fill: parent
		}
		onClicked: {
			mainItem.clicked()
		}
	}
	Text {
		anchors.top: parent.top
		anchors.right: parent.right
		font.weight: 700 * DefaultStyle.dp
		font.pixelSize: 10 * DefaultStyle.dp
		color: DefaultStyle.danger_500main
		text: voicemailCount
		maximumLineCount: 1
	}
}
