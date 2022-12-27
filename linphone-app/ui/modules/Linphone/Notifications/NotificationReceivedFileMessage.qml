import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

import UtilsCpp 1.0

// =============================================================================

Notification {
	id: notification
	
	icon: 'file_sign'
	overrodeHeight: NotificationReceivedFileMessageStyle.overrodeHeight
	
	// ---------------------------------------------------------------------------
	
	readonly property string fileUri: notificationData && notificationData.fileUri || ''
	readonly property string imageUri: notificationData && notificationData.imageUri || ''
	property string systemFileUri: Utils.getUriFromSystemPath(notification.fileUri)
	
	// ---------------------------------------------------------------------------
	
	Loader {
		active: Boolean(notification.fileUri)
		anchors {
			fill: parent
			
			leftMargin: NotificationReceivedFileMessageStyle.leftMargin
			rightMargin: NotificationReceivedFileMessageStyle.rightMargin
		}
		
		sourceComponent: RowLayout {
			anchors.fill: parent
			spacing: NotificationReceivedFileMessageStyle.spacing
			
			Text {
				Layout.fillWidth: true
				
				color: NotificationReceivedFileMessageStyle.fileName.colorModel.color
				elide: Text.ElideRight
				font.pointSize: NotificationReceivedFileMessageStyle.fileName.pointSize
				text: Utils.basename(notification.fileUri)
				visible:!normalImage.visible && !animatedImage.visible
			}
			Loader{
				Layout.fillHeight: true
				Layout.fillWidth: true
				
				sourceComponent: notification.fileUri && UtilsCpp.isAnimatedImage(notification.fileUri) ? animatedImage : normalImage
				active: fileUri || imageUri
				Component{
					id: normalImage
					Image{
						id:image
						mipmap: SettingsModel.mipmapEnabled
						fillMode: Image.PreserveAspectFit
						source: (imageUri ?"image://external/"+notification.imageUri : '')
						visible: image.status == Image.Ready
					}
				}
				Component{
					id: animatedImage
					AnimatedImage{
						id:image
						mipmap: SettingsModel.mipmapEnabled
						fillMode: Image.PreserveAspectFit
						source: (systemFileUri ? systemFileUri: '')
					}
				}
			}
			
			Text {
				Layout.preferredWidth: NotificationReceivedFileMessageStyle.fileSize.width
				
				color: NotificationReceivedFileMessageStyle.fileSize.colorModel.color
				elide: Text.ElideRight
				font.pointSize: NotificationReceivedFileMessageStyle.fileSize.pointSize
				horizontalAlignment: Text.AlignRight
				text: Utils.formatSize(notification.notificationData.fileSize)
			}
		}
		
		MouseArea {
			anchors.fill: parent
			
			onClicked: notification._close(function () {
				if (!Qt.openUrlExternally(systemFileUri)) {
					Qt.openUrlExternally(Utils.dirname(systemFileUri))
				}
			})
		}
	}
}
