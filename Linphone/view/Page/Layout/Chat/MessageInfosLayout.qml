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
	property alias content: contentLayout.children

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
		id: contentLayout
		Layout.leftMargin: Math.round(16 * DefaultStyle.dp)
		Layout.rightMargin: Math.round(16 * DefaultStyle.dp)
		spacing: Math.round(21 * DefaultStyle.dp)
		TabBar {
			id: tabbar
			onCurrentIndexChanged: console.log("current index", currentIndex)
			visible: mainItem.tabbarModel !== undefined
			Layout.fillWidth: true
			Layout.preferredWidth: implicitWidth
            model: mainItem.tabbarModel
			pixelSize: Typography.h4.pixelSize
			textWeight: Typography.h4.weight
			spacing: Math.round(10 * DefaultStyle.dp)
		}

		ListView {
			id: listView
			visible: mainItem.listModel !== undefined
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: Math.round(11 * DefaultStyle.dp)
			model: mainItem.listModel
		}
	}
}
