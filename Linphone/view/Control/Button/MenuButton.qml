import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

Button {
	id: mainItem
	background: Item{}
	icon.width: 32 * DefaultStyle.dp
	icon.height: 32 * DefaultStyle.dp
	textColor: down || checked ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
	contentImageColor: down || checked ? DefaultStyle.main1_500_main : DefaultStyle.main2_500main
	textSize: 14 * DefaultStyle.dp
	textWeight: 400 * DefaultStyle.dp
	textHAlignment: Text.AlignLeft
	spacing: 5 * DefaultStyle.dp
}
