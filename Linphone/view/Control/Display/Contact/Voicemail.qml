import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Rectangle{
	id: mainItem
	property int voicemailCount: 0
	property bool showMwi: false
	property real scaleFactor: 1.0
    width: Utils.getSizeWithScreenRatio(42 * scaleFactor)
    height: Utils.getSizeWithScreenRatio(36 * scaleFactor)
	signal clicked()
	color: 'transparent'
	IconButton {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		style: ButtonStyle.noBackground
		icon.source: AppIcons.voicemail
        width: Utils.getSizeWithScreenRatio(33 * scaleFactor)
		height: width
		icon.width: width
		icon.height: width
		//: "Voicemail"
		Accessible.name: qsTr("voicemail_accessible_name")
		onClicked: {
			mainItem.clicked()
		}
	}
	Text {
		anchors.top: parent.top
		anchors.right: parent.right
        width: Utils.getSizeWithScreenRatio(14 * scaleFactor)
		height: width
		horizontalAlignment: Text.AlignHCenter
        font.weight: Typography.p2.weight
        font.pixelSize: Typography.p2.pixelSize * scaleFactor
		color: DefaultStyle.danger_500_main
		text: voicemailCount >= 100 ? '99+' : voicemailCount
		visible: showMwi && voicemailCount > 0
		maximumLineCount: 1
	}

	Rectangle {
		anchors.top: parent.top
		anchors.right: parent.right
		color: DefaultStyle.danger_500_main
		visible: showMwi && voicemailCount == 0
        width: Utils.getSizeWithScreenRatio(14 * scaleFactor)
		height: width
		radius: width / 2
		EffectImage {
			anchors.fill: parent
            anchors.margins: Utils.getSizeWithScreenRatio(1.5 * scaleFactor)
			imageSource: AppIcons.bell
			colorizationColor: DefaultStyle.grey_0
		}
	}

}
