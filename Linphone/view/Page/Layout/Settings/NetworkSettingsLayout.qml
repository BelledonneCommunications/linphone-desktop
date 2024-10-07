
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import SettingsCpp 1.0
import Linphone

AbstractSettingsLayout {
	contentComponent: content
	Component {
		id: content
		ColumnLayout {
			spacing: 5 * DefaultStyle.dp
			RowLayout {
				spacing: 5 * DefaultStyle.dp
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 5 * DefaultStyle.dp
					ColumnLayout {
						Layout.preferredWidth: 341 * DefaultStyle.dp
						Layout.maximumWidth: 341 * DefaultStyle.dp
						spacing: 5 * DefaultStyle.dp
						Text {
							text: qsTr("Réseau")
							font: Typography.h4
							wrapMode: Text.WordWrap
							color: DefaultStyle.main2_600
							Layout.fillWidth: true
						}
					}
					Item {
						Layout.fillHeight: true
					}
				}
				ColumnLayout {
					Layout.rightMargin: 25 * DefaultStyle.dp
					Layout.topMargin: 36 * DefaultStyle.dp
					Layout.leftMargin: 64 * DefaultStyle.dp
					spacing: 40 * DefaultStyle.dp
					SwitchSetting {
						Layout.fillWidth: true
						titleText: qsTr("Autoriser l'IPv6")
						propertyName: "ipv6Enabled"
						propertyOwner: SettingsCpp
					}
				}
			}
		}
	}
}

