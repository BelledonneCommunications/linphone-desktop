pragma Singleton
import QtQml 2.2
import ColorsList 1.0

// =============================================================================
QtObject{
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
			property color checked: ColorsList.add("Switch_normal_indicator_border_checked", "i").color
			property color disabled: ColorsList.add("Switch_normal_indicator_border_disabled", "c").color
			property color normal: ColorsList.add("Switch_normal_indicator_border_normal", "c").color
		  }
		}
	
		property QtObject color: QtObject {
		  property color checked: ColorsList.add("Switch_normal_indicator_checked", "i").color
		  property color disabled: ColorsList.add("Switch_normal_indicator_disabled", "e").color
		  property color normal: ColorsList.add("Switch_normal_indicator_normal", "q").color
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked: ColorsList.add("Switch_normal_sphere_border_checked", "i").color
			property color disabled: ColorsList.add("Switch_normal_sphere_border_disabled", "c").color
			property color normal: ColorsList.add("Switch_normal_sphere_border_normal", "n").color
			property color pressed: ColorsList.add("Switch_normal_sphere_border_pressed", "n").color
		  }
		}
	
		property QtObject color: QtObject {
		  property color pressed: ColorsList.add("Switch_normal_sphere_pressed", "c").color
		  property color disabled: ColorsList.add("Switch_normal_sphere_disabled", "e").color
		  property color normal: ColorsList.add("Switch_normal_sphere_normal", "q").color
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
			property color checked: ColorsList.add("Switch_aux_indicator_border_checked", "s").color
			property color disabled: ColorsList.add("Switch_aux_indicator_border_disabled", "c").color
			property color normal: ColorsList.add("Switch_aux_indicator_border_normal", "c").color
		  }
		}
	
		property QtObject color: QtObject {
		  property color checked: ColorsList.add("Switch_aux_indicator_checked", "s").color
		  property color disabled: ColorsList.add("Switch_aux_indicator_disabled", "e").color
		  property color normal: ColorsList.add("Switch_aux_indicator_normal", "q").color
		}
	  }
	
	  property QtObject sphere: QtObject {
		property int size: 22
	
		property QtObject border: QtObject {
		  property QtObject color: QtObject {
			property color checked:  ColorsList.add("Switch_aux_sphere_border_checked", "s").color
			property color disabled: ColorsList.add("Switch_aux_sphere_border_disabled", "c").color
			property color normal: ColorsList.add("Switch_aux_sphere_border_normal", "n").color
			property color pressed: ColorsList.add("Switch_aux_sphere_border_pressed", "n").color
		  }
		}
	
		property QtObject color: QtObject {
		  property color pressed: ColorsList.add("Switch_aux_sphere_pressed", "c").color
		  property color disabled: ColorsList.add("Switch_aux_sphere_disabled", "e").color
		  property color normal: ColorsList.add("Switch_aux_sphere_normal", "q").color
		}
	  }
	}
}
