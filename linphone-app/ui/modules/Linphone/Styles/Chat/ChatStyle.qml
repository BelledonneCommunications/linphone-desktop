pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'Chat'
	property color color: ColorsList.add(sectionName, 'q').color
	property string copyTextIcon : 'copy_custom'
	property int rightButtonMargin: 15
	property int rightButtonSize: 30
	property int rightButtonLMargin: 10
	property int separatorHeight: 2
	
	property QtObject sectionHeading: QtObject {
		property int padding: 5
		property int bottomMargin: 20
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_section_border', 'g10').color
			property int width: 1
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property color color: ColorsList.add(sectionName+'_section_text', 'ab').color
		}
	}
	
	property QtObject gotToBottom: QtObject{
		property string name: 'goToBottom'
		property string icon: 'move_to_bottom_custom'
		property int iconSize: 30
		property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg').color
		property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg').color
		property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg').color
		property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg').color
		property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg').color
		property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg').color
	}
	
	property QtObject sendArea: QtObject {
		property int height: 80
		
		property QtObject border: QtObject {
			property color color: ColorsList.add(sectionName+'_send_border', 'f').color
			property int width: 1
		}
		property QtObject backgroundBorder: QtObject {
			property color color: ColorsList.add(sectionName+'_send_background_border', 'ag').color
			property int width: 2
		}
	}
	
	property QtObject composingText: QtObject {
		property color color: ColorsList.add(sectionName+'_composing_text', 'd').color
		property int height: 25
		property int leftPadding: 20
		property int pointSize: Units.dp * 9
	}
	property QtObject replyPreview: QtObject {
		id: replyPreviewObject
		property string name: 'replyPreview'
		property string icon: 'menu_reply_custom'
		property color backgroundColor: ColorsList.add(sectionName+'_'+name+'_bg', 'e').color
		property color headerTextColor: ColorsList.add(sectionName+'_'+name+'_header_fg', 'i').color
		property color iconColor: ColorsList.add(sectionName+'_'+name+'_header_fg', 'i').color
		property color textColor: ColorsList.add(sectionName+'_'+name+'_fg', 'd').color
		property int pointSize: Units.dp * 9
		property int headerPointSize: Units.dp * 9
		property QtObject closeButton: QtObject{
			property int iconSize: rightButtonSize
			property string name : 'close'
			property string icon : 'close_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_b_n', icon, 'l_n_b_bg').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_b_h', icon, 'l_h_b_bg').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_b_p', icon, 'l_p_b_bg').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_f_n', icon, 'l_n_b_fg').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_f_h', icon, 'l_h_b_fg').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_f_p', icon, 'l_p_b_fg').color
		}
	}
	property QtObject messageBanner: QtObject {
		property color color: ColorsList.add(sectionName+'_message_banner', '', 'Background of message banner', '#9ecd1d').color
		property color textColor: ColorsList.add(sectionName+'_message_banner_text', 'q', 'Text of message banner').color
		property int pointSize: Units.dp * 9
	}
	property QtObject ephemeralTimer: QtObject{
		property string icon: 'timer_custom'
		property int iconSize : 25
		property color timerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer', icon, 'ad').color
	}
	
	property QtObject entry: QtObject {
		property int bottomMargin: 10
		property int deleteIconSize: 22
		property int leftMargin: 18
		property int rightMargin: 18
		property int lineHeight: 30
		property int metaWidth: 40
		
		property QtObject separator: QtObject {
			property color color: ColorsList.add(sectionName+'_separator_border', 'g10').color
			property int width: 2
		}
		
		property QtObject menu: QtObject {
			property int iconSize: 22
			property string name : 'menu'
			property string icon : 'chat_menu_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, '','','#DEDEDE').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, '','','#DEDEDE').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, '','','#A1A1A1').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, '', '', '#595759').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, '', '', '#595759').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, '', '', '#595759').color
		}
		property QtObject deleteAction: QtObject {
			property int iconSize: 22
			property string name : 'delete'
			property string icon : 'delete_custom'
			property color backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, '','','#DEDEDE').color
			property color backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, '','','#DEDEDE').color
			property color backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, '','','#A1A1A1').color
			property color foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, '', '', '#595759').color
			property color foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, '', '', '#595759').color
			property color foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, '', '', '#595759').color
		}
		
		property QtObject event: QtObject {
			property int iconSize: 30
			property QtObject notice: QtObject{ 
				property color color: ColorsList.add(sectionName+'_entry_notice', 'ab').color
				property color errorColor: ColorsList.add(sectionName+'_entry_notice_error', 'error').color
				property color importantColor: ColorsList.add(sectionName+'_entry_notice_important', 'ae').color
				property int pointSize: Units.dp * 10
			}
			property QtObject text: QtObject {
				property color color: ColorsList.add(sectionName+'_entry_text', 'ac').color
				property int pointSize: Units.dp * 10
			}
			property QtObject declinedIncomingCall: QtObject{
				property string icon: 'declined_incoming_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_declinedIncomingCall', icon, 'event_bad').color
			}
			property QtObject declinedOutgoingCall: QtObject{
				property string icon: 'declined_outgoing_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_declinedOutgoingCall', icon, 'event_bad').color
			}
			property QtObject endedCall: QtObject{
				property string icon: 'ended_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_endedCall', icon, 'event_neutral').color
			}
			property QtObject incomingCall: QtObject{
				property string icon: 'incoming_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_incomingCall', icon, 'event_in').color
			}
			property QtObject outgoingCall: QtObject{
				property string icon: 'outgoing_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_outgoingCall', icon, 'event_out').color
			}
			property QtObject missedIncomingCall: QtObject{
				property string icon: 'missed_incoming_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_missedIncominCall', icon, 'event_bad').color
			}
			property QtObject missedOutgoingCall: QtObject{
				property string icon: 'missed_outgoing_call_custom'
				property color color: ColorsList.addImageColor(sectionName+'_missedOutgoingCall', icon, 'event_bad').color
			}
			property QtObject unknownCallEvent: QtObject{
				property string icon: 'unknown_call_event'
				property color color: ColorsList.addImageColor(sectionName+'_unknownCallEvent', icon, 'event_bad').color
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
			
			property QtObject file: QtObject {
				property int height: 64
				property int iconSize: 18
				property int margins: 8
				property int spacing: 8
				property int width: 250
				property QtObject download: QtObject{
					property string icon: 'download_custom'
					property int iconSize: 30
					property color outgoingColor: ColorsList.addImageColor(sectionName+'_download_out', icon, 'g').color
					property color incomingColor: ColorsList.addImageColor(sectionName+'_download_in', icon, 'q').color
				}
				
				property QtObject animation: QtObject {
					property int duration: 200
					property real to: 1.5
				}
				
				property QtObject extension: QtObject {
					property QtObject background: QtObject {
						property color color: ColorsList.add(sectionName+'_file_extension_bg', 'l50').color
					}
					
					property QtObject text: QtObject {
						property color color: ColorsList.add(sectionName+'_file_extension_text', 'q').color
					}
				}
				
				property QtObject status: QtObject {
					property int spacing: 4
					
					property QtObject bar: QtObject {
						property int height: 6
						property int radius: 3
						
						property QtObject background: QtObject {
							property color color: ColorsList.add(sectionName+'_file_statusbar_bg', 'f').color
						}
						
						property QtObject contentItem: QtObject {
							property color color: ColorsList.add(sectionName+'_file_statusbar_content', 'p').color
						}
					}
				}
			}
			
			property QtObject images: QtObject {
				property int height: 48
			}
			
			property QtObject incoming: QtObject {
				property color backgroundColor: ColorsList.add(sectionName+'_incoming_bg', 'o').color
				property int avatarSize: 20
				
				property QtObject text: QtObject {
					property color color: ColorsList.add(sectionName+'_incoming_text', 'd').color
					property int pointSize: Units.dp * 10
				}
			}
			
			property QtObject outgoing: QtObject {
				property color backgroundColor: ColorsList.add(sectionName+'_outgoing_bg', 'e').color
				property int areaSize: 16
				property int busyIndicatorSize: 16
				property int sendIconSize: 12
				
				property QtObject text: QtObject {
					property color color: ColorsList.add(sectionName+'_outgoing_text', 'd').color
					property int pointSize: Units.dp * 10
				}
			}
		}
		
		property QtObject time: QtObject {
			property color color: ColorsList.add(sectionName+'_time', 'd').color
			property int pointSize: Units.dp * 10
			property int width: 44
		}
	}
}
