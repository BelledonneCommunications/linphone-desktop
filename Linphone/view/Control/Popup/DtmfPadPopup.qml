import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
import UtilsCpp
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.Popup {
	id: mainItem

	property CallGui call
	property var callState: call ? call.core.state : LinphoneEnums.CallState.Idle
	property bool sendable: !!call && call.core.dtmfSendable
	property var history: call ? call.core.dtmfHistory : []
	property var failedKeys: history.filter(entry => entry.status === "failed").map(entry => entry.key)
	property bool clearable: history.some(entry => entry.status !== "pending")
	property bool pausedLocally: callState === LinphoneEnums.CallState.Paused
		|| callState === LinphoneEnums.CallState.Pausing
		|| callState === LinphoneEnums.CallState.Resuming
	property string unavailableMessage: pausedLocally
		? qsTr("dtmf_pad_call_paused_message")
		: callState === LinphoneEnums.CallState.PausedByRemote
			? qsTr("dtmf_pad_call_paused_by_remote_message")
			: qsTr("dtmf_pad_waiting_media_message")
	readonly property string keys: "123456789*0#"
	property real arrowSize: Utils.getSizeWithScreenRatio(14)
	property bool restoreFocusOnClose: false

	modal: false
	dim: false
	focus: true
	closePolicy: Control.Popup.CloseOnEscape
	width: Utils.getSizeWithScreenRatio(300)
	padding: 0
	x: Math.round((parent.width - width) / 2)
	y: -height - arrowSize - Utils.getSizeWithScreenRatio(4)

	function keyName(key) {
		if (key === "*")
			return qsTr("dtmf_pad_key_star")
		if (key === "#")
			return qsTr("dtmf_pad_key_hash")
		return key
	}

	function historyHtml() {
		var html = ""
		for (var i = 0; i < history.length; ++i) {
			var entry = history[i]
			if (entry.status === "failed")
				html += "<s><font color=\"" + DefaultStyle.danger_500_main + "\">" + entry.key + "</font></s>"
			else if (entry.status === "pending")
				html += "<font color=\"" + DefaultStyle.keypad_text_muted + "\">" + entry.key + "</font>"
			else
				html += entry.key
		}
		return html
	}

	function send(text) {
		if (!call || text.length === 0)
			return
		if (!sendable) {
			unavailableBanner.Accessible.announce(unavailableMessage, Accessible.Assertive)
			return
		}
		call.core.lSendDtmf(text)
	}

	function pressKey(key) {
		var keyButton = keyRepeater.itemAt(keys.indexOf(key))
		if (keyButton && sendable)
			keyButton.flash()
		send(key)
	}

	function focusDefaultItem(reason) {
		var target = sendable ? keyRepeater.itemAt(0) : resumeButton.visible ? resumeButton : closeButton
		if (target)
			target.forceActiveFocus(reason)
	}

	function focusIsInside() {
		var item = mainItem.contentItem.Window.activeFocusItem
		return !!item && Utils.isDescendant(item, mainItem.contentItem)
	}

	onOpened: focusDefaultItem(FocusNavigator.doesLastFocusWasKeyboard() ? Qt.TabFocusReason : Qt.OtherFocusReason)
	onAboutToHide: restoreFocusOnClose = focusIsInside()
	onClosed: {
		if (!restoreFocusOnClose || !parent || !parent.visible || !parent.enabled)
			return
		restoreFocusOnClose = false
		parent.forceActiveFocus(FocusNavigator.doesLastFocusWasKeyboard() ? Qt.TabFocusReason : Qt.OtherFocusReason)
	}
	onSendableChanged: {
		if (!opened)
			return
		if (!sendable)
			unavailableBanner.Accessible.announce(unavailableMessage, Accessible.Polite)
		var item = mainItem.contentItem.Window.activeFocusItem
		if (focusIsInside() && (!item.activeFocusOnTab || !item.enabled))
			Qt.callLater(focusDefaultItem, FocusNavigator.doesLastFocusWasKeyboard() ? Qt.TabFocusReason : Qt.OtherFocusReason)
	}

	background: Item {
		Rectangle {
			id: popupBackground
			anchors.fill: parent
			color: DefaultStyle.keypad_surface
			border.color: DefaultStyle.keypad_border
			border.width: Utils.getSizeWithScreenRatio(1)
			radius: Utils.getSizeWithScreenRatio(20)
		}
		MultiEffect {
			anchors.fill: popupBackground
			source: popupBackground
			shadowEnabled: true
			shadowColor: DefaultStyle.grey_1000
			shadowOpacity: 0.4
			shadowBlur: 0.5
			shadowVerticalOffset: Utils.getSizeWithScreenRatio(4)
			z: -2
		}
		Rectangle {
			width: mainItem.arrowSize
			height: width
			rotation: 45
			x: Math.round((parent.width - width) / 2)
			y: parent.height - height / 2 - popupBackground.border.width
			color: popupBackground.color
			border.color: popupBackground.border.color
			border.width: popupBackground.border.width
			z: -1
		}
		Rectangle {
			width: mainItem.arrowSize * Math.SQRT2 - popupBackground.border.width * 4
			height: mainItem.arrowSize
			x: Math.round((parent.width - width) / 2)
			y: parent.height - height
			color: popupBackground.color
		}
	}

	contentItem: FocusScope {
		id: content
		implicitHeight: contentLayout.implicitHeight
		Accessible.role: Accessible.Dialog
		Accessible.name: qsTr("call_action_show_dialer")
		Accessible.description: subtitle.text

		Keys.onPressed: event => {
			if (event.matches(StandardKey.Paste)) {
				mainItem.send(UtilsCpp.getClipboardText().replace(/[^0-9*#,]/g, ""))
				event.accepted = true
				return
			}
			if (event.modifiers & (Qt.ControlModifier | Qt.MetaModifier | Qt.AltModifier))
				return
			if (event.isAutoRepeat || event.text.length !== 1 || "0123456789*#,".indexOf(event.text) < 0)
				return
			mainItem.pressKey(event.text)
			event.accepted = true
		}

		ColumnLayout {
			id: contentLayout
			anchors.fill: parent
			spacing: 0

			RowLayout {
				Layout.fillWidth: true
				Layout.topMargin: Utils.getSizeWithScreenRatio(16)
				Layout.leftMargin: Utils.getSizeWithScreenRatio(20)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(12)
				Layout.bottomMargin: Utils.getSizeWithScreenRatio(12)
				spacing: 0
				ColumnLayout {
					Layout.fillWidth: true
					spacing: Utils.getSizeWithScreenRatio(4)
					Text {
						Layout.fillWidth: true
						text: qsTr("call_action_show_dialer")
						color: DefaultStyle.keypad_text
						font: Typography.h4
						Accessible.role: Accessible.Heading
						Accessible.name: text
					}
					Text {
						id: subtitle
						Layout.fillWidth: true
						text: mainItem.call ? qsTr("dtmf_pad_subtitle").arg(mainItem.call.core.remoteName) : ""
						color: DefaultStyle.keypad_text_muted
						font.family: DefaultStyle.defaultFont
						font.pixelSize: Utils.getSizeWithScreenRatio(12)
						elide: Text.ElideRight
						Accessible.role: Accessible.StaticText
						Accessible.name: text
					}
				}
				Button {
					id: closeButton
					Layout.alignment: Qt.AlignTop
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(32)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(32)
					padding: 0
					radius: Utils.getSizeWithScreenRatio(16)
					style: ButtonStyle.noBackground
					contentImageColor: DefaultStyle.keypad_icon
					hoveredImageColor: DefaultStyle.keypad_text
					pressedImageColor: DefaultStyle.keypad_text
					keyboardFocusedBorderColor: DefaultStyle.grey_0
					icon.source: AppIcons.keypadClose
					icon.width: Utils.getSizeWithScreenRatio(20)
					icon.height: Utils.getSizeWithScreenRatio(20)
					Accessible.name: qsTr("close_numeric_pad_accessible_name")
					onClicked: mainItem.close()
				}
			}

			Rectangle {
				Layout.fillWidth: true
				Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(52)
				radius: height / 2
				color: DefaultStyle.keypad_field
				border.width: Utils.getSizeWithScreenRatio(sentText.activeFocus && sentText.keyboardFocus ? 2 : 1)
				border.color: sentText.activeFocus ? DefaultStyle.keypad_text : DefaultStyle.keypad_border

				Item {
					anchors.left: parent.left
					anchors.right: clearButton.visible ? clearButton.left : parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: Utils.getSizeWithScreenRatio(20)
					anchors.rightMargin: clearButton.visible ? Utils.getSizeWithScreenRatio(8) : Utils.getSizeWithScreenRatio(20)
					height: Utils.getSizeWithScreenRatio(28)
					clip: true

					Text {
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						visible: mainItem.history.length === 0
						text: qsTr("dtmf_pad_placeholder")
						color: DefaultStyle.keypad_text_muted
						font.family: DefaultStyle.defaultFont
						font.pixelSize: Utils.getSizeWithScreenRatio(14)
						Accessible.ignored: true
					}

					TextEdit {
						id: sentText
						property bool keyboardFocus: FocusHelper.keyboardFocus
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						width: Math.max(implicitWidth, Utils.getSizeWithScreenRatio(4))
						textFormat: TextEdit.RichText
						text: mainItem.historyHtml()
						readOnly: true
						selectByMouse: true
						selectByKeyboard: true
						persistentSelection: true
						activeFocusOnTab: true
						cursorVisible: false
						textMargin: 0
						wrapMode: TextEdit.NoWrap
						color: DefaultStyle.keypad_text
						selectionColor: DefaultStyle.main1_500_main
						selectedTextColor: DefaultStyle.grey_0
						font.family: DefaultStyle.defaultFont
						font.pixelSize: Utils.getSizeWithScreenRatio(22)
						font.letterSpacing: Utils.getSizeWithScreenRatio(2)
						cursorDelegate: Item {}
						Accessible.role: Accessible.EditableText
						Accessible.name: qsTr("dtmf_pad_field_accessible_name")
						Accessible.description: mainItem.failedKeys.length > 0
							? qsTr("dtmf_pad_failed_accessible_description").arg(mainItem.failedKeys.map(mainItem.keyName).join(", "))
							: ""
					}
				}
				Button {
					id: clearButton
					anchors.right: parent.right
					anchors.rightMargin: Utils.getSizeWithScreenRatio(12)
					anchors.verticalCenter: parent.verticalCenter
					width: Utils.getSizeWithScreenRatio(32)
					height: Utils.getSizeWithScreenRatio(32)
					padding: 0
					radius: Utils.getSizeWithScreenRatio(16)
					visible: mainItem.clearable
					style: ButtonStyle.noBackground
					contentImageColor: DefaultStyle.keypad_icon
					hoveredImageColor: DefaultStyle.keypad_text
					pressedImageColor: DefaultStyle.keypad_text
					keyboardFocusedBorderColor: DefaultStyle.grey_0
					icon.source: AppIcons.closeX
					icon.width: Utils.getSizeWithScreenRatio(18)
					icon.height: Utils.getSizeWithScreenRatio(18)
					Accessible.name: qsTr("dtmf_pad_clear_accessible_name")
					onClicked: {
						var refocus = activeFocus
						if (mainItem.call)
							mainItem.call.core.clearDtmfHistory()
						if (refocus)
							sentText.forceActiveFocus(FocusNavigator.doesLastFocusWasKeyboard() ? Qt.TabFocusReason : Qt.OtherFocusReason)
					}
				}
			}

			Text {
				Layout.fillWidth: true
				Layout.topMargin: Utils.getSizeWithScreenRatio(8)
				Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
				visible: mainItem.failedKeys.length > 0
				text: qsTr("dtmf_pad_failed_legend")
				color: DefaultStyle.danger_500_main
				font.family: DefaultStyle.defaultFont
				font.pixelSize: Utils.getSizeWithScreenRatio(12)
				wrapMode: Text.WordWrap
				Accessible.role: Accessible.StaticText
				Accessible.name: text
			}

			RowLayout {
				id: unavailableBanner
				Layout.fillWidth: true
				Layout.topMargin: Utils.getSizeWithScreenRatio(8)
				Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
				visible: !mainItem.sendable && (mainItem.pausedLocally || mainItem.callState === LinphoneEnums.CallState.PausedByRemote)
				spacing: Utils.getSizeWithScreenRatio(10)
				Text {
					Layout.fillWidth: true
					text: mainItem.unavailableMessage
					color: DefaultStyle.main2_300
					font.family: DefaultStyle.defaultFont
					font.pixelSize: Utils.getSizeWithScreenRatio(12)
					wrapMode: Text.WordWrap
					Accessible.role: Accessible.StaticText
					Accessible.name: text
				}
				SmallButton {
					id: resumeButton
					visible: mainItem.callState === LinphoneEnums.CallState.Paused
					style: ButtonStyle.main
					text: qsTr("dtmf_pad_resume_button")
					Accessible.name: qsTr("call_action_resume_call")
					onClicked: if (mainItem.call) mainItem.call.core.lSetPaused(false)
				}
			}

			GridLayout {
				id: keyGrid
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: Utils.getSizeWithScreenRatio(16)
				Layout.bottomMargin: Utils.getSizeWithScreenRatio(8)
				columns: 3
				rowSpacing: Utils.getSizeWithScreenRatio(12)
				columnSpacing: Utils.getSizeWithScreenRatio(26)

				Repeater {
					id: keyRepeater
					model: mainItem.keys.length
					Button {
						id: keyButton
						required property int index
						property string key: mainItem.keys[index]
						property bool flashed: false
						function flash() {
							flashed = true
							flashTimer.restart()
						}
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(64)
						Layout.preferredHeight: Utils.getSizeWithScreenRatio(64)
						enabled: mainItem.sendable
						style: ButtonStyle.numericPadDark
						radius: height / 2
						disabledFilterColor: DefaultStyle.keypad_surface
						borderColor: pressed || flashed ? DefaultStyle.main1_500_main : "transparent"
						borderWidth: Utils.getSizeWithScreenRatio(pressed || flashed ? 2 : 1)
						Accessible.name: mainItem.keyName(key)
						contentItem: Text {
							text: keyButton.key
							color: DefaultStyle.keypad_text
							horizontalAlignment: Text.AlignHCenter
							verticalAlignment: Text.AlignVCenter
							font.family: DefaultStyle.defaultFont
							font.pixelSize: Utils.getSizeWithScreenRatio(26)
							font.weight: Font.Medium
							Accessible.ignored: true
						}
						KeyNavigation.left: keyRepeater.itemAt((index + 11) % 12)
						KeyNavigation.right: keyRepeater.itemAt((index + 1) % 12)
						KeyNavigation.up: keyRepeater.itemAt((index + 9) % 12)
						KeyNavigation.down: keyRepeater.itemAt((index + 3) % 12)
						onClicked: mainItem.send(key)
						Timer {
							id: flashTimer
							interval: 250
							onTriggered: keyButton.flashed = false
						}
					}
				}
			}

			Text {
				Layout.fillWidth: true
				Layout.topMargin: Utils.getSizeWithScreenRatio(10)
				Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
				Layout.bottomMargin: Utils.getSizeWithScreenRatio(16)
				text: mainItem.sendable ? qsTr("dtmf_pad_keyboard_hint") : qsTr("dtmf_pad_keyboard_inactive_hint")
				color: DefaultStyle.keypad_text_muted
				font.family: DefaultStyle.defaultFont
				font.pixelSize: Utils.getSizeWithScreenRatio(11)
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.WordWrap
				Accessible.role: Accessible.StaticText
				Accessible.name: text
			}
		}
	}
}
