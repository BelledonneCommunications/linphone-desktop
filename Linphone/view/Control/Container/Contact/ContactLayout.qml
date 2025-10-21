import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

ColumnLayout {
	id: mainItem
    spacing: Utils.getSizeWithScreenRatio(30)

	property FriendGui contact

	property alias button: rightButton
	property alias content: detailLayout.data
	property alias bannerContent: bannerLayout.data
	property alias secondLineContent: verticalLayoutSecondLine.data
    property real minimumWidthForSwitchintToRowLayout: Utils.getSizeWithScreenRatio(756)
    property var useVerticalLayout: width < minimumWidthForSwitchintToRowLayout

	GridLayout {
        Layout.leftMargin: Utils.getSizeWithScreenRatio(64)
        Layout.rightMargin: Utils.getSizeWithScreenRatio(64)
        Layout.topMargin: Utils.getSizeWithScreenRatio(56)
		Layout.fillWidth: true
		columns: mainItem.useVerticalLayout ? 1 : children.length
		rows: 1
        columnSpacing: Utils.getSizeWithScreenRatio(49)
        rowSpacing: Utils.getSizeWithScreenRatio(27)

		ColumnLayout {
			spacing: Utils.getSizeWithScreenRatio(16)
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(341)
			RowLayout {
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(341)
				Control.Control {
					// Layout.preferredWidth: Utils.getSizeWithScreenRatio(734)
					Layout.fillWidth: true
					width: Utils.getSizeWithScreenRatio(734)
					height: Utils.getSizeWithScreenRatio(100)
					rightPadding: Utils.getSizeWithScreenRatio(21)
					background: GradientRectangle {
						anchors.fill: parent
						anchors.leftMargin: avatar.width / 2
						radius: Utils.getSizeWithScreenRatio(15)
						borderGradient: Gradient {
							orientation: Gradient.Horizontal
							GradientStop { position: 0.0; color: DefaultStyle.grey_100 }
							GradientStop { position: 1.0; color: DefaultStyle.main2_200 }
						}
						gradient: Gradient {
							orientation: Gradient.Horizontal
							GradientStop { position: 0.0; color: DefaultStyle.grey_0 }
							GradientStop { position: 1.0; color: DefaultStyle.grey_100 }
						}
					}
					contentItem: RowLayout {
						id: bannerLayout
						spacing: Utils.getSizeWithScreenRatio(32)
						Avatar {
							id: avatar
							contact: mainItem.contact
							Layout.preferredWidth: Utils.getSizeWithScreenRatio(100)
							Layout.preferredHeight: Utils.getSizeWithScreenRatio(100)
						}
					}
				}
			}
			PresenceNoteLayout {
				visible: contact?.core.presenceNote.length > 0 && mainItem.useVerticalLayout
				friendCore: contact?.core || null
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(412)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(85)
			}
		}
		Item {
			id: verticalLayoutSecondLine
			visible: mainItem.useVerticalLayout
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: childrenRect.width
			Layout.preferredHeight: childrenRect.height
		}
		MediumButton {
			id: rightButton
			Layout.alignment: Qt.AlignHCenter
			style: ButtonStyle.main
		}
	}
	Rectangle {
		Layout.fillWidth:true
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(79)
		color: 'transparent'
		visible: contact && contact.core.presenceNote.length > 0 && !mainItem.useVerticalLayout
		PresenceNoteLayout {
			anchors.centerIn: parent
			friendCore: contact?.core || null
			width: Utils.getSizeWithScreenRatio(412)
			height: Utils.getSizeWithScreenRatio(85)
		}
	}
	StackLayout {
		id: detailLayout
		Layout.alignment: Qt.AlignCenter
        Layout.topMargin: mainItem.useVerticalLayout ? 0 : Utils.getSizeWithScreenRatio(30)
        Layout.leftMargin: Utils.getSizeWithScreenRatio(64)
        Layout.rightMargin: Utils.getSizeWithScreenRatio(64)
        Layout.bottomMargin: Utils.getSizeWithScreenRatio(53)
		Layout.fillWidth: true
		Layout.fillHeight: true
	}
}
