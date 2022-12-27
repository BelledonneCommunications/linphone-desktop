// TextButtonBStyle (Primary)
pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'TextButtonB'
	property QtObject backgroundColor: QtObject {
		property var disabled: ColorsList.add(sectionName+'_bg_d', 'i30')
		property var hovered: ColorsList.add(sectionName+'_bg_h', 'b')
		property var normal: ColorsList.add(sectionName+'_bg_n', 'i')
		property var pressed: ColorsList.add(sectionName+'_bg_p', 'm')
	}
	
	property QtObject textColor: QtObject {
		property var disabled: ColorsList.add(sectionName+'_text_d', 'q')
		property var hovered: ColorsList.add(sectionName+'_text_h', 'q')
		property var normal: ColorsList.add(sectionName+'_text_n', 'q')
		property var pressed: ColorsList.add(sectionName+'_text_p', 'q')
	}
	property QtObject borderColor : backgroundColor
}
