import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Popup {
	id: mainItem
	closePolicy: Control.Popup.CloseOnEscape
	padding: Utils.getSizeWithScreenRatio(10)
	property bool closeButtonVisible: true
	property bool roundedBottom: false
	property bool lastRowVisible: true
	property var currentCall
	focus: true
	onOpened: {
		const focusReason = FocusNavigator.doesLastFocusWasKeyboard() ? Qt.TabFocusReason : Qt.OtherFocusReason
		numPad.forceActiveFocus(focusReason)
	}
	signal buttonPressed(string text)
	signal keyPadKeyPressed(KeyEvent event)
	onKeyPadKeyPressed: (event) => {
		numPad.handleKeyPadEvent(event)
	}
	signal launchCall()
	signal wipe()

	background: Item {
		anchors.fill: parent
		Rectangle {
			id: numPadBackground
			width: parent.width
			height: parent.height
			color: DefaultStyle.grey_100
            radius: Utils.getSizeWithScreenRatio(20)
			bottomLeftRadius: mainItem.roundedBottom ? radius : 0
			bottomRightRadius: mainItem.roundedBottom ? radius : 0
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
		MouseArea {
			anchors.fill: parent
			onClicked: numPad.forceActiveFocus()
		}
	}
	contentItem: ColumnLayout{
		Accessible.role: Accessible.Dialog
		//: "Numeric Pad"
		Accessible.name : qsTr("numeric_pad_accessible_name")
		BigButton {
			id: closeButton
			visible: mainItem.closeButtonVisible
			Layout.alignment: Qt.AlignRight
			icon.source: AppIcons.closeX
            icon.width: Utils.getSizeWithScreenRatio(24)
            icon.height: Utils.getSizeWithScreenRatio(24)
			style: ButtonStyle.noBackground
			onClicked: mainItem.close()
			//: Close numeric pad
			Accessible.name: qsTr("close_numeric_pad_accessible_name")
		}
		NumericPad{
			id: numPad
			Layout.alignment: Qt.AlignCenter
			Layout.bottomMargin: Utils.getSizeWithScreenRatio(5)
			lastRowVisible: mainItem.lastRowVisible
			currentCall: mainItem.currentCall
			onButtonPressed: (text) => {
				mainItem.buttonPressed(text)
			}
			onLaunchCall: mainItem.launchCall()
			onWipe: mainItem.wipe()
		}
	}
}
