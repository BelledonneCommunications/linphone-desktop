pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================
QtObject {
	property string sectionName: 'TextField'
	property QtObject normal : QtObject {
		property QtObject background: QtObject {
			property int height: 36
			property int width: 200
			
			property int radius: 4
			
			property QtObject border: QtObject {
				property QtObject color: QtObject {
					property var error: ColorsList.add(sectionName+'_n_bg_border_error', 'error')
					property var normal: ColorsList.add(sectionName+'_n_bg_border_n', 'c')
					property var selected: ColorsList.add(sectionName+'_n_bg_border_c', 'i')
				}
				
				property int width: 1
			}
			
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_n_bg_n', 'q')
				property var readOnly: ColorsList.add(sectionName+'_n_bg_readonly', 'e')
			}
			property QtObject mandatory: QtObject{
				property var colorModel: ColorsList.add(sectionName+'_required_text', 'g')
				property real pointSize: Units.dp * 10
			}
		}
		
		property QtObject text: QtObject {
			property var normal: ColorsList.add(sectionName+'_n_text', 'd')
			property var readOnly: ColorsList.add(sectionName+'_n_text_readonly', 'd')
			property int pointSize: Units.dp * 10
			property int rightPadding: 5
		}
	}
	property QtObject unbordered : QtObject {
		property QtObject background: QtObject {
			property int height: 36
			property int width: 200
			
			property int radius: 4
			
			property QtObject border: QtObject {
				property QtObject color: QtObject {
					property var error: {'color':'black'}
					property var normal: {'color':'black'}
					property var selected: {'color':'black'}
				}
				
				property int width: 0
			}
			
			property QtObject color: QtObject {
				property var normal:  ColorsList.add(sectionName+'_unbordered_bg_n', 'q')
				property var readOnly: ColorsList.add(sectionName+'_unbordered_bg_readonly', 'e')
			}
			property QtObject mandatory: QtObject{
				property var colorModel: ColorsList.add(sectionName+'_unbordered_required_text', 'g')
				property real pointSize: Units.dp * 10
			}
		}
		
		property QtObject text: QtObject {
			property var normal: ColorsList.add(sectionName+'_unbordered_text', 'd')
			property var readOnly: ColorsList.add(sectionName+'_unbordered_text_readonly', 'd')
			property int pointSize: Units.dp * 10
			property int rightPadding: 5
		}
	}
	property QtObject flat : QtObject {
		property QtObject background: QtObject {
			property int height: 36
			property int width: 200
			
			property int radius: 0
			
			property QtObject border: QtObject {
				property QtObject color: QtObject {
					property var error: {'color':'black'}
					property var normal: {'color':'black'}
					property var selected: {'color':'black'}
				}
				
				property int width: 0
			}
			
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_flat_bg_n', 'q')
				property var readOnly: ColorsList.add(sectionName+'_flat_bg_readonly', 'e')
			}
			property QtObject mandatory: QtObject{
				property var colorModel: ColorsList.add(sectionName+'_flat_required_text', 'g')
				property real pointSize: Units.dp * 10
			}
		}
		
		property QtObject text: QtObject {
			property var normal: ColorsList.add(sectionName+'_flat_text', 'd')
			property var readonly: ColorsList.add(sectionName+'_flat_text_readonly', 'd')
			property int pointSize: Units.dp * 10
			property int rightPadding: 5
		}
	}
	property QtObject flatInverse : QtObject {
		property QtObject background: QtObject {
			property int height: 36
			property int width: 200
			
			property int radius: 0
			
			property QtObject border: QtObject {
				property QtObject color: QtObject {
					property var error: {'color':'black'}
					property var normal: {'color':'black'}
					property var selected: {'color':'black'}
				}
				
				property int width: 0
			}
			
			property QtObject color: QtObject {
				property var normal: ColorsList.add(sectionName+'_flat_inv_bg_n', 'q')
				property var readOnly: ColorsList.add(sectionName+'_flat_inv_bg_readonly', 'q')
			}
			property QtObject mandatory: QtObject{
				property var colorModel: ColorsList.add(sectionName+'_flat_inv_required_text', 'g')
				property real pointSize: Units.dp * 10
			}
		}
		
		property QtObject text: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_flat_inv_text', 'd')
			property var readOnly: ColorsList.add(sectionName+'_flat_inv_readonly', 'readonly_fg')
			property int pointSize: Units.dp * 10
			property int rightPadding: 5
		}
	}
}
