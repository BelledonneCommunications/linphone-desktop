// TextButtonCStyle		(Green)
pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'TextButtonC'
	property QtObject backgroundColor: QtObject {
		property color disabled: ColorsList.add(sectionName+'_bg_d', 'i30').color
		property color hovered: ColorsList.add(sectionName+'_bg_h', 'validation_h').color
		property color normal: ColorsList.add(sectionName+'_bg_n', 'validation').color
		property color pressed: ColorsList.add(sectionName+'_bg_p', 'i').color
	}
	
	property QtObject textColor: QtObject {
		property color disabled: ColorsList.add(sectionName+'_text_d', 'q').color
		property color hovered: ColorsList.add(sectionName+'_text_h', 'q').color
		property color normal: ColorsList.add(sectionName+'_text_n', 'q').color
		property color pressed: ColorsList.add(sectionName+'_text_p', 'q').color
	}
	property QtObject borderColor : backgroundColor
}
