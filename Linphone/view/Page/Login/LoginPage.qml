import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls as Control
import Linphone

LoginLayout {
	id: root
	signal useSIPButtonClicked()

	titleContent: RowLayout {
		Image {
			fillMode: Image.PreserveAspectFit
			source: AppIcons.profile
		}
		Text {
			text: "Login"
			color: DefaultStyle.titleColor
			font.pointSize: DefaultStyle.title2FontPointSize
			font.bold: true
			scaleLettersFactor: 1.1
		}
		Item {
			Layout.fillWidth: true
		}
		Text {
			Layout.rightMargin: 15
			text: "No account yet ?"
			color: DefaultStyle.defaultTextColor
			font.pointSize: DefaultStyle.defaultTextSize
		}
		Button {
			Layout.alignment: Qt.AlignRight
			inversedColors: true
			text: "Register"
		}
	}

	centerContent: LoginForm {
		onUseSIPButtonClicked: root.useSIPButtonClicked()
	}
}
 
