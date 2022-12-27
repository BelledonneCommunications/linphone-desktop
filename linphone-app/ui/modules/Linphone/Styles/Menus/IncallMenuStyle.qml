pragma Singleton
import QtQml 2.2
import QtQuick 2.7

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'IncallMenu'
	property var backgroundColor: ColorsList.add(sectionName+'_bg', 'k')
	property int radius: 8
	property QtObject header: QtObject{
		property string name: 'header'
		property int height: 60		
		property var colorModel: ColorsList.add(sectionName+'_'+name+'_fg', 'j')
		property int weight: Font.Bold
		property int pointSize: Units.dp * 14
	}
	property QtObject list : QtObject{
		property string name: 'list'
		property int height: 60
		property var colorModel: ColorsList.add(sectionName+'_'+name+'_fg', 'j')
		property int weight: Font.Normal
		property int selectedWeight: Font.Bold
		property int pointSize: Units.dp * 12
		
		property QtObject border: QtObject{
			property var colorModel: ColorsList.add(sectionName+'_list_border', 'f')
			property int width: 2
		}
	}
	
	property QtObject modeIcons: QtObject{
		property string gridIcon: 'conference_layout_grid_custom'
		property string activeSpeakerIcon: 'conference_layout_active_speaker_custom'
		property string audioOnlyIcon: 'conference_audio_only_custom'
		property int width: 40
		property int height: 40
	}
	property QtObject settingsIcons: QtObject{
		property string gridIcon: 'conference_layout_grid_custom'
		property string activeSpeakerIcon: 'conference_layout_active_speaker_custom'
		property string audioOnlyIcon: 'conference_audio_only_custom'
		property string mediaIcon: 'micro_on_custom'
		property string participantsIcon: 'participants_custom'
		property int width: 40
		property int height: 40
	}
	
	//------------------------------------------------------------------------------
	property QtObject buttons: QtObject{
		property QtObject close: QtObject {
			property int iconSize: 40
			property string icon : 'close_custom'
			property string name : 'close'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
		}
		property QtObject back: QtObject {
			property int iconSize: 40
			property string icon : 'back_custom'
			property string name : 'back'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
		}
		property QtObject next: QtObject {
			property int iconSize: 40
			property string icon : 'panel_arrow_custom'
			property string name : 'next'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'me_h_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'me_n_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'me_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'me_h_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'me_n_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'me_p_b_fg')
		}
		
	}
	//------------------------------------------------------------------------------		
	
}
