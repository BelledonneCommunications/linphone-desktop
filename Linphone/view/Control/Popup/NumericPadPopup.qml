import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts as Layout
import QtQuick.Effects
import Linphone
import UtilsCpp
import LinphoneCallsCpp

Control.Popup {
	id: mainItem
	closePolicy: Control.Popup.CloseOnEscape
	leftPadding: 72 * DefaultStyle.dp
	rightPadding: 72 * DefaultStyle.dp
	topPadding: 41 * DefaultStyle.dp
	bottomPadding: 18 * DefaultStyle.dp
	property bool closeButtonVisible: true
	property bool roundedBottom: false
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
			radius: 20 * DefaultStyle.dp
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
		Button {
			id: closeButton
			visible: mainItem.closeButtonVisible
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.topMargin: 10 * DefaultStyle.dp
			anchors.rightMargin: 10 * DefaultStyle.dp
			background: Item {
				anchors.fill: parent
				visible: false
			}
			icon.source: AppIcons.closeX
			width: 24 * DefaultStyle.dp
			height: 24 * DefaultStyle.dp
			icon.width: 24 * DefaultStyle.dp
			icon.height: 24 * DefaultStyle.dp
			onClicked: mainItem.close()
		}
	}
	contentItem: NumericPad{
		id: numPad
		currentCall: mainItem.currentCall
		anchors.fill: parent
		anchors.topMargin: 41 * DefaultStyle.dp
		anchors.bottomMargin: 18 * DefaultStyle.dp
		anchors.rightMargin: 72 * DefaultStyle.dp
		anchors.leftMargin: 72 * DefaultStyle.dp
		onButtonPressed: (text) => {
			console.log("BUTTON PRESSED NUMPAD")
			mainItem.buttonPressed(text)}
	}
}
