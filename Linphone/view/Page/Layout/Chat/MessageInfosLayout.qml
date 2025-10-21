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
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

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

	spacing: Utils.getSizeWithScreenRatio(25)

	signal goBackRequested()

	RowLayout {
		BigButton {
			icon.source: AppIcons.leftArrow
			style: ButtonStyle.noBackground
			onClicked: mainItem.goBackRequested()
		}
		Text {
			text: mainItem.title
			font: Typography.h4
		}
	}

	ColumnLayout {
		id: contentLayout
		Layout.leftMargin: Utils.getSizeWithScreenRatio(16)
		Layout.rightMargin: Utils.getSizeWithScreenRatio(16)
		spacing: Utils.getSizeWithScreenRatio(21)
		TabBar {
			id: tabbar
			visible: mainItem.tabbarModel !== undefined
			Layout.fillWidth: true
			Layout.preferredWidth: implicitWidth
            model: mainItem.tabbarModel
			pixelSize: Typography.h4.pixelSize
			textWeight: Typography.h4.weight
			spacing: Utils.getSizeWithScreenRatio(10)
		}

		ListView {
			id: listView
			visible: mainItem.listModel !== undefined
			Layout.fillWidth: true
			Layout.fillHeight: true
			spacing: Utils.getSizeWithScreenRatio(11)
			model: mainItem.listModel
		}
	}
}
