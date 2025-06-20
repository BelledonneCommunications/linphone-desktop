import QtCore
import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Layouts
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

ColumnLayout {
	id: mainItem

	property string title
	property ChatMessageGui chatMessageGui
	property var tabbarModel
	property var listModel
	property var listDelegate
	property alias tabbar: tabbar
	property alias listView: listView
	property var parentView

	spacing: Math.round(25 * DefaultStyle.dp)

	signal goBackRequested()

	RowLayout {
		BigButton {
			icon.source: AppIcons.leftArrow
			style: ButtonStyle.noBackground
			onClicked: mainItem.goBackRequested()
		}
		Text {
			text: mainItem.title
			font {
				pixelSize: Typography.h4.pixelSize
				weight: Typography.h4.weight
			}
		}
	}

	ColumnLayout {
		spacing: Math.round(21 * DefaultStyle.dp)
		Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(16 * DefaultStyle.dp)
		TabBar {
			id: tabbar
			Layout.fillWidth: true
            model: mainItem.tabbarModel
			pixelSize: Typography.h3m.pixelSize
			textWeight: Typography.h3m.weight
		}

		ListView {
			id: listView
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: Math.round(11 * DefaultStyle.dp)
			model: mainItem.listModel
		}
	}
}
