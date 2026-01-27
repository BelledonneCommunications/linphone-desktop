import QtCore
import QtQuick
import QtQuick.Layouts
import Linphone
import UtilsCpp
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

MessageInfosLayout {
	id: mainItem
	spacing: Utils.getSizeWithScreenRatio(25)
	property ChatGui chatGui
	property int filter
	property bool showAsSquare: false
	tabbar.visible: false

	content: [
		GridView {
			id: gridView
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.preferredHeight: contentHeight
			cellWidth: mainItem.filter === ChatMessageFileProxy.FilterContentType.Documents ? width : Math.round(width / 4)
			cellHeight: mainItem.filter === ChatMessageFileProxy.FilterContentType.Documents ? Utils.getSizeWithScreenRatio(69) : Math.round(width / 4)
			property bool loading: true
			model: ChatMessageFileProxy {
				chat: mainItem.chatGui
				filterType: mainItem.filter
				onModelAboutToBeReset: gridView.loading = true
				onModelReset: gridView.loading = false
			}
			BusyIndicator {
				anchors.centerIn: parent
				visible: gridView.loading
			}
			Text {
				anchors.centerIn: parent
				visible: !gridView.loading && gridView.count === 0
				font: Typography.p2l
				text: mainItem.filter === ChatMessageFileProxy.FilterContentType.Medias
				//: No media
				? qsTr("no_shared_medias")
				//: No document
				: qsTr("no_shared_documents")
			}
			delegate: FileView {
				contentGui: modelData
				showAsSquare: mainItem.showAsSquare
				width: gridView.cellWidth - Utils.getSizeWithScreenRatio(2)
				height: gridView.cellHeight - Utils.getSizeWithScreenRatio(2)
			}
		},
		Item{Layout.fillHeight: true}
	]
}