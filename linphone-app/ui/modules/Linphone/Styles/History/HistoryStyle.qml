pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName: 'History'
	property var colorModel: ColorsList.add(sectionName, 'q')
	
	property QtObject sectionHeading: QtObject {
		property int padding: 5
		property int bottomMargin: 20
		
		property QtObject border: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_section_border', 'g10')
			property int width: 1
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property var colorModel: ColorsList.add(sectionName+'_section_text', 'g')
		}
	}
	
	
	property QtObject entry: QtObject {
		property int bottomMargin: 10
		property int leftMargin: 18
		property int lineHeight: 30
		property int metaWidth: 40
		
		property QtObject deleteAction: QtObject {
			property int iconSize: 30
			property string name : 'delete'
			property string icon : 'delete_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'l_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'l_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'l_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'l_p_b_fg')
		}
		
		property QtObject event: QtObject {
			property int iconSize: 30
			
			property QtObject text: QtObject {
				property var colorModel: ColorsList.add(sectionName+'_event_text', 'd')
				property int pointSize: Units.dp * 10
			}
			
			property QtObject declinedIncomingCall: QtObject{
				property string icon: 'declined_incoming_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_declinedIncomingCall', icon, 'event_bad')
			}
			property QtObject declinedOutgoingCall: QtObject{
				property string icon: 'declined_outgoing_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_declinedOutgoingCall', icon, 'event_bad')
			}
			property QtObject endedCall: QtObject{
				property string icon: 'ended_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_endedCall', icon, 'event_neutral')
			}
			property QtObject incomingCall: QtObject{
				property string icon: 'incoming_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_incomingCall', icon, 'event_in')
			}
			property QtObject outgoingCall: QtObject{
				property string icon: 'outgoing_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_outgoingCall', icon, 'event_out')
			}
			property QtObject missedIncomingCall: QtObject{
				property string icon: 'missed_incoming_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_missedIncominCall', icon, 'event_bad')
			}
			property QtObject missedOutgoingCall: QtObject{
				property string icon: 'missed_outgoing_call_custom'
				property var colorModel: ColorsList.addImageColor(sectionName+'_missedOutgoingCall', icon, 'event_bad')
			}
			property QtObject unknownCallEvent: QtObject{
				property string icon: 'unknown_call_event'
				property var colorModel: ColorsList.addImageColor(sectionName+'_unknownCallEvent', icon, 'event_bad')
			}
		}
		
		property QtObject message: QtObject {
			property int padding: 8
			property int radius: 4
			
			property QtObject extraContent: QtObject {
				property int leftMargin: 10
				property int spacing: 5
				property int rightMargin: 5
			}
		}
		
		property QtObject time: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_time', 'd')
			property int pointSize: Units.dp * 10
			property int width: 44
		}
	}
}
