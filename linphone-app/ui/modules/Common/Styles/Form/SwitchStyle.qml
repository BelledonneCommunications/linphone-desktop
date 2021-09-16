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
			property color checked: ColorsList.add(sectionName+'_n_indicator_border_c', 'i').color
			property color disabled: ColorsList.add(sectionName+'_n_indicator_border_d', 'c').color
			property color normal: ColorsList.add(sectionName+'_n_indicator_border_n', 'c').color
		  }
		}
	
		property QtObject color: QtObject {
		  property color checked: ColorsList.add(sectionName+'_n_indicator_c', 'i').color
		  property color disabled: ColorsList.add(sectionName+'_n_indicator_d', 'e').color
		  property color normal: ColorsList.add(sectionName+'_n_indicator_n', 'q').color
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked: ColorsList.add(sectionName+'_n_sphere_border_c', 'i').color
			property color disabled: ColorsList.add(sectionName+'_n_sphere_border_d', 'c').color
			property color normal: ColorsList.add(sectionName+'_n_sphere_border_n', 'n').color
			property color pressed: ColorsList.add(sectionName+'_n_sphere_border_p', 'n').color
		  }
		}
	
		property QtObject color: QtObject {
		  property color pressed: ColorsList.add(sectionName+'_n_sphere_p', 'c').color
		  property color disabled: ColorsList.add(sectionName+'_n_sphere_d', 'e').color
		  property color normal: ColorsList.add(sectionName+'_n_sphere_n', 'q').color
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
			property color checked: ColorsList.add(sectionName+'_aux_indicator_border_c', 's').color
			property color disabled: ColorsList.add(sectionName+'_aux_indicator_border_d', 'c').color
			property color normal: ColorsList.add(sectionName+'_aux_indicator_border_n', 'c').color
		  }
		}
	
		property QtObject color: QtObject {
		  property color checked: ColorsList.add(sectionName+'_aux_indicator_c', 's').color
		  property color disabled: ColorsList.add(sectionName+'_aux_indicator_d', 'e').color
		  property color normal: ColorsList.add(sectionName+'_aux_indicator_n', 'q').color
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked:  ColorsList.add(sectionName+'_aux_sphere_border_c', 's').color
			property color disabled: ColorsList.add(sectionName+'_aux_sphere_border_d', 'c').color
			property color normal: ColorsList.add(sectionName+'_aux_sphere_border_n', 'n').color
			property color pressed: ColorsList.add(sectionName+'_aux_sphere_border_p', 'n').color
		  }
		}
	
		property QtObject color: QtObject {
		  property color pressed: ColorsList.add(sectionName+'_aux_sphere_p', 'c').color
		  property color disabled: ColorsList.add(sectionName+'_aux_sphere_d', 'e').color
		  property color normal: ColorsList.add(sectionName+'_aux_sphere_n', 'q').color
		}
	  }
	}
}
