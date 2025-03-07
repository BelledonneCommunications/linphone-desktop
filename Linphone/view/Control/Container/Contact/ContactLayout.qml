import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem
    spacing: Math.round(30 * DefaultStyle.dp)

	property FriendGui contact

	property alias button: rightButton
	property alias content: detailLayout.data
	property alias bannerContent: bannerLayout.data
	property alias secondLineContent: verticalLayoutSecondLine.data
    property real minimumWidthForSwitchintToRowLayout: Math.round(756 * DefaultStyle.dp)
    property var useVerticalLayout: width < minimumWidthForSwitchintToRowLayout

	GridLayout {
        Layout.leftMargin: Math.round(64 * DefaultStyle.dp)
        Layout.rightMargin: Math.round(64 * DefaultStyle.dp)
        Layout.topMargin: Math.round(56 * DefaultStyle.dp)
		Layout.fillWidth: true
		columns: mainItem.useVerticalLayout ? 1 : children.length
		rows: 1
        columnSpacing: Math.round(49 * DefaultStyle.dp)
        rowSpacing: Math.round(27 * DefaultStyle.dp)

		RowLayout {
            Layout.preferredWidth: Math.round(341 * DefaultStyle.dp)
			Control.Control {
                // Layout.preferredWidth: Math.round(734 * DefaultStyle.dp)
				Layout.fillWidth: true
                width: Math.round(734 * DefaultStyle.dp)
                height: Math.round(100 * DefaultStyle.dp)
                rightPadding: Math.round(21 * DefaultStyle.dp)
				background: GradientRectangle {
					anchors.fill: parent
					anchors.leftMargin: avatar.width / 2
                    radius: Math.round(15 * DefaultStyle.dp)
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
                    spacing: Math.round(32 * DefaultStyle.dp)
					Avatar {
						id: avatar
						contact: mainItem.contact
                        Layout.preferredWidth: Math.round(100 * DefaultStyle.dp)
                        Layout.preferredHeight: Math.round(100 * DefaultStyle.dp)
					}
				}
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
	StackLayout {
		id: detailLayout
		Layout.alignment: Qt.AlignCenter
        Layout.topMargin: mainItem.useVerticalLayout ? 0 : Math.round(30 * DefaultStyle.dp)
        Layout.leftMargin: Math.round(64 * DefaultStyle.dp)
        Layout.rightMargin: Math.round(64 * DefaultStyle.dp)
        Layout.bottomMargin: Math.round(53 * DefaultStyle.dp)
		Layout.fillWidth: true
		Layout.fillHeight: true
	}
}
