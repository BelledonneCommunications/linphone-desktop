import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp

ColumnLayout {
	id: mainItem
	spacing: 30 * DefaultStyle.dp

	property FriendGui contact

	property alias button: rightButton
	property alias content: detailLayout.data
	property alias bannerContent: bannerLayout.data

	RowLayout {
		spacing: 49 * DefaultStyle.dp
		Layout.leftMargin: 64 * DefaultStyle.dp
		Layout.rightMargin: 64 * DefaultStyle.dp
		Layout.topMargin: 56 * DefaultStyle.dp
		Control.Control {
			// Layout.preferredWidth: 734 * DefaultStyle.dp
			Layout.fillWidth: true
			width: 734 * DefaultStyle.dp
			height: 100 * DefaultStyle.dp
			rightPadding: 21 * DefaultStyle.dp
			background: GradientRectangle {
				anchors.fill: parent
				anchors.leftMargin: avatar.width / 2
				radius: 15 * DefaultStyle.dp
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
				spacing: 32 * DefaultStyle.dp
				Avatar {
					id: avatar
					contact: mainItem.contact
					Layout.preferredWidth: 100 * DefaultStyle.dp
					Layout.preferredHeight: 100 * DefaultStyle.dp
				}
			}
		}
		Button {
			id: rightButton
			width: childrenRect.width
			height: childrenRect.height
		}
	}
	StackLayout {
		id: detailLayout
		Layout.alignment: Qt.AlignCenter
		Layout.topMargin: 30 * DefaultStyle.dp
		Layout.leftMargin: 64 * DefaultStyle.dp
		Layout.rightMargin: 64 * DefaultStyle.dp
		Layout.bottomMargin: 53 * DefaultStyle.dp
		Layout.fillWidth: true
		Layout.fillHeight: true
	}
}
