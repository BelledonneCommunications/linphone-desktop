pragma Singleton
import QtQml 2.2

import Units 1.0
import ColorsList 1.0

// =============================================================================

QtObject {
	property string sectionName : 'Chat'
	property var colorModel: ColorsList.add(sectionName, 'q')
	property string copyTextIcon : 'menu_copy_text_custom'
	property int rightButtonMargin: 15
	property int rightButtonSize: 30
	property int rightButtonLMargin: 10
	property int separatorHeight: 2
	
	property QtObject sectionHeading: QtObject {
		property int padding: 5
		property int bottomMargin: 20
		
		property QtObject border: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_section_border', 'g10')
			property int width: 1
		}
		
		property QtObject text: QtObject {
			property int pointSize: Units.dp * 10
			property var colorModel: ColorsList.add(sectionName+'_section_text', 'ab')
		}
	}
	
	property QtObject gotToBottom: QtObject{
		property string name: 'goToBottom'
		property string icon: 'move_to_bottom_custom'
		property int iconSize: 30
		property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_n', icon, 's_n_b_bg')
		property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_h', icon, 's_h_b_bg')
		property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_b_p', icon, 's_p_b_bg')
		property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_n', icon, 's_n_b_fg')
		property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_h', icon, 's_h_b_fg')
		property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_f_p', icon, 's_p_b_fg')
	}
	
	property QtObject sendArea: QtObject {
		property int height: 80
		
		property QtObject border: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_send_border', 'f')
			property int width: 1
		}
		property QtObject backgroundBorder: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_send_background_border', 'ag')
			property int width: 2
		}
	}
	
	property QtObject composingText: QtObject {
		property var colorModel: ColorsList.add(sectionName+'_composing_text', 'd')
		property int height: 25
		property int leftPadding: 20
		property int pointSize: Units.dp * 9
	}
	property QtObject replyPreview: QtObject {
		id: replyPreviewObject
		property string name: 'replyPreview'
		property string icon: 'menu_reply_custom'
		property var backgroundColor: ColorsList.add(sectionName+'_'+name+'_bg', 'e')
		property var headerTextColor: ColorsList.add(sectionName+'_'+name+'_header_fg', 'i')
		property var iconColor: ColorsList.add(sectionName+'_'+name+'_header_fg', 'i')
		property var textColor: ColorsList.add(sectionName+'_'+name+'_fg', 'd')
		property int pointSize: Units.dp * 9
		property int headerPointSize: Units.dp * 9
		property QtObject closeButton: QtObject{
			property int iconSize: rightButtonSize
			property string name : 'close'
			property string icon : 'close_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_b_n', icon, 'l_n_b_bg')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_b_h', icon, 'l_h_b_bg')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_b_p', icon, 'l_p_b_bg')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_f_n', icon, 'l_n_b_fg')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_f_h', icon, 'l_h_b_fg')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+replyPreviewObject.name+'_'+name+'_f_p', icon, 'l_p_b_fg')
		}
	}
	property QtObject ephemeralTimer: QtObject{
		property string icon: 'timer_custom'
		property int iconSize : 25
		property var timerColor: ColorsList.addImageColor(sectionName+'_ephemeralTimer', icon, 'ad')
	}
	
	property QtObject entry: QtObject {
		property int bottomMargin: 10
		property int deleteIconSize: 22
		property int leftMargin: 18
		property int rightMargin: 18
		property int lineHeight: 30
		property int metaWidth: 40
		
		property QtObject separator: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_separator_border', 'g10')
			property int width: 2
		}
		
		property QtObject menu: QtObject {
			property int iconSize: 22
			property string name : 'menu'
			property string icon : 'chat_menu_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, '','','#DEDEDE')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, '','','#DEDEDE')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, '','','#A1A1A1')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, '', '', '#595759')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, '', '', '#595759')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, '', '', '#595759')
		}
		property QtObject deleteAction: QtObject {
			property int iconSize: 22
			property string name : 'delete'
			property string icon : 'delete_custom'
			property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, '','','#DEDEDE')
			property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, '','','#DEDEDE')
			property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, '','','#A1A1A1')
			property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, '', '', '#595759')
			property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, '', '', '#595759')
			property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, '', '', '#595759')
		}
		
		property QtObject event: QtObject {
			property int iconSize: 30
			property QtObject notice: QtObject{ 
				property var colorModel: ColorsList.add(sectionName+'_entry_notice', 'ab')
				property var errorColor: ColorsList.add(sectionName+'_entry_notice_error', 'error')
				property var importantColor: ColorsList.add(sectionName+'_entry_notice_important', 'ae')
				property int pointSize: Units.dp * 10
			}
			property QtObject text: QtObject {
				property var colorModel: ColorsList.add(sectionName+'_entry_text', 'ac')
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
			property int radius: 8
			
			property QtObject extraContent: QtObject {
				property int leftMargin: 10
				property int spacing: 5
				property int rightMargin: 5
			}
			
			property QtObject file: QtObject {
				property int height: 120
				property int heightbetter: 200
				property int iconSize: 18
				property int margins: 8
				property int spacing: 8
				property int width: 100
				
				property QtObject name: QtObject{
					property int pointSize: Units.dp * 7
				}
				
				property QtObject download: QtObject{
					property string icon: 'download_custom'
					property int height: 20
					property int pointSize: Units.dp * 8
					property int iconSize: 30
					property var outgoingColor: ColorsList.addImageColor(sectionName+'_download_out', icon, 'g')
					property var incomingColor: ColorsList.addImageColor(sectionName+'_download_in', icon, 'q')
				}
				property QtObject thumbnailVideoIcon: QtObject {
					property int iconSize: 40
					property string name : 'play'
					property string icon : 'thumbnail_video_custom'
					property var backgroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_n', icon, 'wr_n_b_bg')
					property var backgroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_h', icon, 'wr_h_b_bg')
					property var backgroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_bg_p', icon, 'wr_p_b_bg')
					property var foregroundNormalColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_n', icon, 'wr_n_b_fg')
					property var foregroundHoveredColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_h', icon, 'wr_h_b_fg')
					property var foregroundPressedColor : ColorsList.addImageColor(sectionName+'_'+name+'_fg_p', icon, 'wr_p_b_fg')
				}
				property QtObject animation: QtObject {
					property int duration: 300
					property real to: 1.7
					property real thumbnailTo: 2
				}
				
				property QtObject extension: QtObject {
					property string icon:  'file_extension_custom'
					property int iconSize: 60
					property int internalSize: 37
					property int radius: 0
					
					property QtObject background: QtObject {
						property var colorModel: ColorsList.add(sectionName+'_file_extension_bg', 'q')
						property var borderColorModel: ColorsList.add(sectionName+'_file_extension_border', 'extension_file_border')
					}
					
					property QtObject text: QtObject {
						property var colorModel: ColorsList.add(sectionName+'_file_extension_text', 'd')
						property int pointSize: Units.dp * 9
					}
				}
				
				property QtObject status: QtObject {
					property int spacing: 4
					
					property QtObject bar: QtObject {
						property int height: 6
						property int radius: 3
						
						property QtObject background: QtObject {
							property var colorModel: ColorsList.add(sectionName+'_file_statusbar_bg', 'f')
						}
						
						property QtObject contentItem: QtObject {
							property var colorModel: ColorsList.add(sectionName+'_file_statusbar_content', 'p')
						}
					}
				}
			}
			
			property QtObject images: QtObject {
				property int height: 240
				property int width: 240
			}	
			
			property QtObject incoming: QtObject {
				property var backgroundColor: ColorsList.add(sectionName+'_incoming_bg', 'incoming_bg')
				property int avatarSize: 30
				
				property QtObject text: QtObject {
					property var colorModel: ColorsList.add(sectionName+'_incoming_text', 'd')
					property int pointSize: Units.dp * 10
				}
			}
			
			property QtObject outgoing: QtObject {
				property var backgroundColor: ColorsList.add(sectionName+'_outgoing_bg', 'outgoing_bg')
				property int areaSize: 32
				property int busyIndicatorSize: 12
				property int sendIconSize: 12
				
				property QtObject text: QtObject {
					property var colorModel: ColorsList.add(sectionName+'_outgoing_text', 'd')
					property int pointSize: Units.dp * 10
				}
			}
		}
		
		property QtObject time: QtObject {
			property var colorModel: ColorsList.add(sectionName+'_time', 'd')
			property int pointSize: Units.dp * 10
			property int width: 70
		}
		property QtObject date: QtObject {
			property int pointSize: Units.dp * 8
		}
	}
}
