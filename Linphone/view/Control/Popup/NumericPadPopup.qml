import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts as Layout
import QtQuick.Effects
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Control.Popup {
	id: mainItem
	closePolicy: Control.Popup.CloseOnEscape
    leftPadding: Math.round(72 * DefaultStyle.dp)
    rightPadding: Math.round(72 * DefaultStyle.dp)
    topPadding: Math.round(41 * DefaultStyle.dp)
    bottomPadding: Math.round(18 * DefaultStyle.dp)
	property bool closeButtonVisible: true
	property bool roundedBottom: false
	property bool lastRowVisible: true
	property var currentCall
	onOpened: numPad.forceActiveFocus()
	signal buttonPressed(string text)
	signal launchCall()
	signal wipe()

	background: Item {
		anchors.fill: parent
		Rectangle {
			id: numPadBackground
			width: parent.width
			height: parent.height
			color: DefaultStyle.grey_100
            radius: Math.round(20 * DefaultStyle.dp)
		}
		MultiEffect {
			id: effect
			anchors.fill: numPadBackground
			source: numPadBackground
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowOpacity: 0.1
			shadowBlur: 0.1
			z: -1
		}
		Rectangle {
			width: parent.width
			height: parent.height / 2
			anchors.bottom: parent.bottom
			color: DefaultStyle.grey_100
			visible: !mainItem.roundedBottom
		}
		MouseArea {
			anchors.fill: parent
			onClicked: numPad.forceActiveFocus()
		}
		BigButton {
			id: closeButton
			visible: mainItem.closeButtonVisible
			anchors.top: parent.top
			anchors.right: parent.right
            anchors.topMargin: Math.round(10 * DefaultStyle.dp)
            anchors.rightMargin: Math.round(10 * DefaultStyle.dp)
			icon.source: AppIcons.closeX
            icon.width: Math.round(24 * DefaultStyle.dp)
            icon.height: Math.round(24 * DefaultStyle.dp)
			style: ButtonStyle.noBackground
			onClicked: mainItem.close()
		}
	}
	contentItem: NumericPad{
		id: numPad
		lastRowVisible: mainItem.lastRowVisible
		currentCall: mainItem.currentCall
		onButtonPressed: (text) => {
			console.log("BUTTON PRESSED NUMPAD")
			mainItem.buttonPressed(text)
		}
		onLaunchCall: mainItem.launchCall()
		onWipe: mainItem.wipe()
	}
}
