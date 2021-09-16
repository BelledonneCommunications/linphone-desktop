pragma Singleton
import QtQml 2.2
import ColorsList 1.0
// =============================================================================

QtObject {
	property string sectionName: 'Busy'
	property color color: ColorsList.add(sectionName+'_indicator', 'i').color
	property int duration: 1250
	property int nSpheres: 6
}
