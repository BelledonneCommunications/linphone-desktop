import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: labelButton
	// property alias image: buttonImg
	property alias button: button
	property alias text: text
	property string label
	spacing: Utils.getSizeWithScreenRatio(8)
	Button {
		id: button
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: Utils.getSizeWithScreenRatio(56)
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(56)
		topPadding: Utils.getSizeWithScreenRatio(16)
		bottomPadding: Utils.getSizeWithScreenRatio(16)
		leftPadding: Utils.getSizeWithScreenRatio(16)
		rightPadding: Utils.getSizeWithScreenRatio(16)
		contentImageColor: DefaultStyle.main2_600
		radius: Utils.getSizeWithScreenRatio(40)
		style: ButtonStyle.grey
		Accessible.name: labelButton.label
	}
	Text {
		id: text
		Layout.alignment: Qt.AlignHCenter
		text: labelButton.label
		font {
			pixelSize: Typography.p1.pixelSize
			weight: Typography.p1.weight
		}
	}
}
