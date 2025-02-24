import QtQuick
import Linphone

Flickable {
	width: parent.width
	contentWidth: contentItem.childrenRect.width
	contentHeight: contentItem.childrenRect.height
	clip: true
    flickableDirection: Flickable.VerticalFlick
}
