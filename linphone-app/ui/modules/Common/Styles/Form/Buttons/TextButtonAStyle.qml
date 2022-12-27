pragma Singleton
import QtQml 2.2
// TextButtonAStyle (Grey)
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'TextButtonA'
	property QtObject backgroundColor: QtObject {
		property var disabled: ColorsList.add(sectionName+'_bg_d', 'o')
		property var hovered: ColorsList.add(sectionName+'_bg_h', 'j')
		property var normal: ColorsList.add(sectionName+'_bg_n', 'r')
		property var pressed: ColorsList.add(sectionName+'_bg_p', 'i')
	}
	
	property QtObject textColor: QtObject {
		property var disabled: ColorsList.add(sectionName+'_text_d', 'q')
		property var hovered: ColorsList.add(sectionName+'_text_h', 'q')
		property var normal: ColorsList.add(sectionName+'_text_n', 'q')
		property var pressed: ColorsList.add(sectionName+'_text_p', 'q')
	}
	property QtObject borderColor : backgroundColor
}
