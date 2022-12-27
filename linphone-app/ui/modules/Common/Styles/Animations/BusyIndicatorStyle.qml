pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Busy'
	property var colorModel: ColorsList.add(sectionName+'_indicator', 'q')
	property var alternateColor: ColorsList.add(sectionName+'_indicator_alt', 'i')
	property int duration: 1250
	property int nSpheres: 8
}
