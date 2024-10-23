import QtQuick
import Linphone

Flickable {
	width: contentWidth
	contentWidth: contentItem.childrenRect.width
	contentHeight: contentItem.childrenRect.height
	clip: true
	flickableDirection: Flickable.VerticalFlick
}