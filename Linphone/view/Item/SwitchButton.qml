import QtQuick 2.7
import QtQuick.Controls 2.2 as Control
import Linphone
  
Control.AbstractButton {
	id: mainItem
	checkable: true
	width: 32 * DefaultStyle.dp
	height: 20 * DefaultStyle.dp
	EffectImage {
		visible: mainItem.checked
		imageSource: AppIcons.switchOn
		//colorizationColor: DefaultStyle.success_500main - not working on this icon.
		anchors.fill: parent
	}
	EffectImage {
		visible: !mainItem.checked
		imageSource: AppIcons.switchOff
		//colorizationColor: DefaultStyle.main2_400 - not working on this icon.
		anchors.fill: parent
	}
}
