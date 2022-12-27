pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================
QtObject{
	property string sectionName: 'Switch'
	property QtObject normal :QtObject {
	  property QtObject animation: QtObject {
		property int duration: 200
	  }
	
	  property QtObject indicator: QtObject {
		property int height: 18
		property int radius: 10
		property int width: 48
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property var checked: ColorsList.add(sectionName+'_n_indicator_border_c', 'i')
			property var disabled: ColorsList.add(sectionName+'_n_indicator_border_d', 'c')
			property var normal: ColorsList.add(sectionName+'_n_indicator_border_n', 'c')
		  }
		}
	
		property QtObject color: QtObject {
		  property var checked: ColorsList.add(sectionName+'_n_indicator_c', 'i')
		  property var disabled: ColorsList.add(sectionName+'_n_indicator_d', 'e')
		  property var normal: ColorsList.add(sectionName+'_n_indicator_n', 'q')
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property var checked: ColorsList.add(sectionName+'_n_sphere_border_c', 'i')
			property var disabled: ColorsList.add(sectionName+'_n_sphere_border_d', 'c')
			property var normal: ColorsList.add(sectionName+'_n_sphere_border_n', 'n')
			property var pressed: ColorsList.add(sectionName+'_n_sphere_border_p', 'n')
		  }
		}
	
		property QtObject color: QtObject {
		  property var pressed: ColorsList.add(sectionName+'_n_sphere_p', 'c')
		  property var disabled: ColorsList.add(sectionName+'_n_sphere_d', 'e')
		  property var normal: ColorsList.add(sectionName+'_n_sphere_n', 'q')
		}
	  }
	}
	property QtObject aux : QtObject{
	  property QtObject animation: QtObject {
		property int duration: 200
	  }
	
	  property QtObject indicator: QtObject {
		property int height: 18
		property int radius: 10
		property int width: 48
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property var checked: ColorsList.add(sectionName+'_aux_indicator_border_c', 's')
			property var disabled: ColorsList.add(sectionName+'_aux_indicator_border_d', 'c')
			property var normal: ColorsList.add(sectionName+'_aux_indicator_border_n', 'c')
		  }
		}
	
		property QtObject color: QtObject {
		  property var checked: ColorsList.add(sectionName+'_aux_indicator_c', 's')
		  property var disabled: ColorsList.add(sectionName+'_aux_indicator_d', 'e')
		  property var normal: ColorsList.add(sectionName+'_aux_indicator_n', 'q')
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property var checked:  ColorsList.add(sectionName+'_aux_sphere_border_c', 's')
			property var disabled: ColorsList.add(sectionName+'_aux_sphere_border_d', 'c')
			property var normal: ColorsList.add(sectionName+'_aux_sphere_border_n', 'n')
			property var pressed: ColorsList.add(sectionName+'_aux_sphere_border_p', 'n')
		  }
		}
	
		property QtObject color: QtObject {
		  property var pressed: ColorsList.add(sectionName+'_aux_sphere_p', 'c')
		  property var disabled: ColorsList.add(sectionName+'_aux_sphere_d', 'e')
		  property var normal: ColorsList.add(sectionName+'_aux_sphere_n', 'q')
		}
	  }
	}
}
