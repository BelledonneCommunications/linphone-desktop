pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0


// =============================================================================

QtObject {
	property string sectionName: 'InfoEncryption'
	property int height: 353
	property int width: 450
	
	property QtObject mainLayout: QtObject {
		property int topMargin: 15
		property int leftMargin: 10
		property int rightMargin: 10
		property int spacing: 0
	}
	
	property QtObject okButton : QtObject{
		property QtObject backgroundColor: QtObject {
			property var disabled: ColorsList.add(sectionName+'_ok_bg_d', 'i30')
			property var hovered: ColorsList.add(sectionName+'_ok_bg_h', 'b')
			property var normal: ColorsList.add(sectionName+'_ok_bg_n', 's')
			property var pressed: ColorsList.add(sectionName+'_ok_bg_p', 'm')
		}
		
		property QtObject textColor: QtObject {
			property var disabled: ColorsList.add(sectionName+'_ok_text_d', 'q')
			property var hovered: ColorsList.add(sectionName+'_ok_text_h', 'q')
			property var normal: ColorsList.add(sectionName+'_ok_text_n', 'q')
			property var pressed: ColorsList.add(sectionName+'_ok_text_p', 'q')
		}
	}
	
	property QtObject securityIcon: QtObject{
		property int iconSize: 40
		property int preferredHeight: 50
		property int preferredWidth: 50
	}
	
	property QtObject descriptionText: QtObject{
		property int leftMargin: 10
		property int rightMargin: 10
		property real pointSize: Units.dp * 11
		property var colorModel: ColorsList.add(sectionName+'_description', 'd')
	}
}