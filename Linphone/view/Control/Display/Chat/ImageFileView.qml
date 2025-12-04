import QtQuick
import QtQuick.Controls as Control
import QtQuick.Layouts
import QtMultimedia

import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// =============================================================================


// ---------------------------------------------------------------------
// Separated file to show a single image bigger in chat message
// The FileView file does not allow that as it is a Loader and the image
// is reloaded everytime the message becomes visible again. It causes the
// chat message not to be able to adapt its size according to the painted
// size of the image
// ---------------------------------------------------------------------
Image {
	id: mainItem
	property ChatMessageContentGui contentGui

	mipmap: false//SettingsModel.mipmapEnabled
	autoTransform: true
	fillMode: Image.PreserveAspectFit
	source: contentGui && contentGui.core.thumbnail || ""

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		propagateComposedEvents: true
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		// Changing cursor in MouseArea seems not to work with the Loader
		// Use override cursor for this case
		onContainsMouseChanged: {
			if (containsMouse) UtilsCpp.setGlobalCursor(Qt.PointingHandCursor)
			else UtilsCpp.restoreGlobalCursor()
		}
		onPressed: (mouse) => {
			mouse.accepted = true
			// if(SettingsModel.isVfsEncrypted){
			//     window.attachVirtualWindow(Utils.buildCommonDialogUri('FileViewDialog'), {
			//                                 contentGui: mainItem.contentGui,
			//                             }, function (status) {
			//                             })
			// }else
			mainItem.contentGui.core.lOpenFile()
		}
	}
}
