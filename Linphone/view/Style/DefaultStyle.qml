pragma Singleton
import QtQuick

QtObject {
    property color main1_100: "#FFEACB"
    property color main1_200: "#FFD098"
    property color main1_300: "#FFB266"
    property color main1_500_main: "#FE5E00"
    property color main1_600: "#DA4400"
    property color main1_700: "#B72D00"

    property color main2_0: "#FAFEFF"
    property color main2_100: "#EEF6F8"
    property color main2_200: "#DFECF2"
    property color main2_300: "#C0D1D9"
    property color main2_400: "#9AABB5"
    property color main2_500main: "#6C7A87"
    property color main2_600: "#4E6074"
    property color main2_700: "#364860"
    property color main2_800: "#22334D"
    property color main2_900: "#2D3648"

    property color grey_0: "#FFFFFF"
    property color grey_100: "#F9F9F9"
    property color grey_200: "#EDEDED"
    property color grey_300: "#C9C9C9"
    property color grey_400: "#949494"
    property color grey_500: "#4E4E4E"
    property color grey_600: "#2E3030"
    property color grey_850: "#D9D9D9"
    property color grey_900: "#070707"
    property color grey_1000: "#000000"

    property color warning_600: "#DBB820"
    property color danger_500main: "#DD5F5F"
    property color danger_700: "#9E3548"
    property color danger_900: "#723333"
    property color success_500main: "#4FAE80"
    property color success_700: "#377d71"
    property color success_900: "#1E4C53"
    property color info_500_main: "#4AA8FF"

    property color vue_meter_light_green: "#6FF88D"
    property color vue_meter_dark_green: "#00D916"

    property real defaultHeight: 1080.0
    property real defaultWidth: 1920.0
    property double dp: (Screen.width/Screen.height)/(defaultWidth/defaultHeight)

    onDpChanged: {
        console.log("Screen ratio changed", dp)
    }

    // Warning: Qt 6.8.1 (current version) and previous versions, Qt only support COLRv0 fonts. Don't try to use v1.
    property string emojiFont: "OpenMoji Color"
    property string flagFont: "OpenMoji Color"
    property string defaultFont: "Noto Sans"

    property color numericPadPressedButtonColor: "#EEF7F8"

    property color groupCallButtonColor: "#EEF7F8"

    property color placeholders: '#CACACA'	// No name in design
    
	property color warning_500_main: "#FFDC2E"
}
