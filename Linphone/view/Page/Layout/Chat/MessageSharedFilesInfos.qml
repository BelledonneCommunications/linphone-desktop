import QtCore
import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp

MessageInfosLayout {
	id: mainItem
	spacing: Math.round(25 * DefaultStyle.dp)
	property ChatGui chatGui
	property int filter
	tabbar.visible: false

	content: [
		GridView {
			id: gridView
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.preferredHeight: contentHeight
			cellWidth: mainItem.filter === ChatMessageFileProxy.FilterContentType.Documents ? width : width / 4
			cellHeight: mainItem.filter === ChatMessageFileProxy.FilterContentType.Documents ? Math.round(69 * DefaultStyle.dp) : width / 4
			model: ChatMessageFileProxy {
				chat: mainItem.chatGui
				filterType: mainItem.filter
			}
			delegate: FileView {
				contentGui: modelData
				showAsSquare: false
				width: gridView.cellWidth - Math.round(2 * DefaultStyle.dp)
				height: gridView.cellHeight - Math.round(2 * DefaultStyle.dp)
			}
		},
		Item{Layout.fillHeight: true}
	]
}