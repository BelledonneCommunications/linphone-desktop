import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: labelButton
	// property alias image: buttonImg
	property alias button: button
	property alias text: text
	property string label
	spacing: Math.round(8 * DefaultStyle.dp)
	Button {
		id: button
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: Math.round(56 * DefaultStyle.dp)
		Layout.preferredHeight: Math.round(56 * DefaultStyle.dp)
		topPadding: Math.round(16 * DefaultStyle.dp)
		bottomPadding: Math.round(16 * DefaultStyle.dp)
		leftPadding: Math.round(16 * DefaultStyle.dp)
		rightPadding: Math.round(16 * DefaultStyle.dp)
		contentImageColor: DefaultStyle.main2_600
		radius: Math.round(40 * DefaultStyle.dp)
		style: ButtonStyle.grey
	}
	Text {
		id: text
		Layout.alignment: Qt.AlignHCenter
		Layout.fillWidth: true
		text: labelButton.label
		font {
			pixelSize: Typography.p1.pixelSize
			weight: Typography.p1.weight
		}
	}
}
