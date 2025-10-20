import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import QtQml
import Linphone
import CustomControls 1.0
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Control.Button {
	id: mainItem
	property var style
    property bool asynchronous: false
	hoverEnabled: enabled
	activeFocusOnTab: true
	property color disabledFilterColor: color.hslLightness > 0.5
		? DefaultStyle.grey_0
		: DefaultStyle.grey_400
	property bool hasNavigationFocus: enabled && (activeFocus || hovered)
	property bool keyboardFocus: FocusHelper.keyboardFocus
	// Background properties
	property color color: style?.color?.normal || DefaultStyle.main1_500_main
	property color hoveredColor: style?.color?.hovered || Qt.darker(color, 1.05)
    property color pressedColor: style?.color?.pressed || Qt.darker(color, 1.1)
    property color checkedColor: style?.color?.checked || style?.color?.pressed || Qt.darker(color, 1.1)
	property bool shadowEnabled: false
	property int capitalization
	property color backgroundColor: mainItem.checkable && mainItem.checked
                    ? mainItem.checkedColor || mainItem.pressedColor
                    : mainItem.pressed
                        ? mainItem.pressedColor
                        : mainItem.hovered
                            ? mainItem.hoveredColor
                            : mainItem.color
	// Text properties
	property bool underline: false
    property real textSize: Utils.getSizeWithScreenRatio(18)
    property real textWeight: Typography.b1.weight
    property color textColor: style?.text?.normal || DefaultStyle.grey_0
	property color hoveredTextColor: style?.text?.hovered || Qt.darker(textColor, 1.05)
	property color pressedTextColor: style?.text?.pressed || Qt.darker(textColor, 1.1)
	property var textFormat: Text.AutoText
	property var textHAlignment: Text.AlignHCenter
	// Tooltip properties
	ToolTip.visible: hovered && ToolTip.text != ""
	ToolTip.delay: 500
	// Border properties
	property color borderColor: style?.borderColor?.normal || "transparent"
	property color keyboardFocusedBorderColor: style?.borderColor?.keybaordFocused || DefaultStyle.main2_900
	property real borderWidth: Utils.getSizeWithScreenRatio(1)
	property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)
	// Image properties
	property var contentImageColor: style?.image?.normal || DefaultStyle.main2_600
	property var hoveredImageColor: style?.image?.pressed || Qt.darker(contentImageColor, 1.05)
	property var checkedImageColor: style?.image?.checked || Qt.darker(contentImageColor, 1.1)
	property var pressedImageColor: style?.image?.pressed || Qt.darker(contentImageColor, 1.1)
	icon.source: style?.iconSource || ""
	property color colorizationColor:  mainItem.checkable && mainItem.checked ? mainItem.checkedImageColor : mainItem.pressed ? mainItem.pressedImageColor : mainItem.hovered ? mainItem.hoveredImageColor : mainItem.contentImageColor
	// Size properties
	spacing: Utils.getSizeWithScreenRatio(5)
    property real radius: Math.ceil(height / 2)

	MouseArea {
		id: mouseArea
		z: stacklayout.z + 1
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		acceptedButtons: Qt.NoButton
	}
	
	background: Loader{
		asynchronous: mainItem.asynchronous
		anchors.fill: parent
		
		sourceComponent: Item {
			width: mainItem.width
			height: mainItem.height
			Rectangle {
				id: buttonBackground
				anchors.fill: parent
                color: mainItem.backgroundColor
				radius: mainItem.radius
				border.color: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderColor : mainItem.borderColor
				border.width: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth 
			}
			MultiEffect {
				enabled: mainItem.shadowEnabled
				anchors.fill: buttonBackground
				source: buttonBackground
				visible:  mainItem.shadowEnabled
				// Crash : https://bugreports.qt.io/browse/QTBUG-124730
				shadowEnabled: true
				shadowColor: DefaultStyle.grey_1000
				shadowBlur: 0.1
				shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
			}
		}
	}

	Rectangle {
		id: disableShadow
		z: 1
		// color: buttonBackground.color == "transparent" ? "transparent" : "white"
		color: disabledFilterColor
		opacity: 0.5
		visible: !mainItem.enabled && mainItem.color.a !== 0
		radius: mainItem.radius
		width: mainItem.width
		height: mainItem.height
	}
	
	component ButtonText: Text {
		id: buttonText
		horizontalAlignment: mainItem.textHAlignment
		verticalAlignment: Text.AlignVCenter
		width: textMetrics.advanceWidth
		wrapMode: Text.WrapAnywhere
		text: mainItem.text
		textFormat: mainItem.textFormat
		maximumLineCount: 1
        color: mainItem.checkable && mainItem.checked || mainItem.pressed
			? mainItem.pressedTextColor
			: mainItem.hovered
				? mainItem.hoveredTextColor
				: mainItem.textColor
		font {
			pixelSize: mainItem.textSize
			weight: mainItem.textWeight
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
			underline: mainItem.underline
			bold: (mainItem.style === ButtonStyle.noBackground || mainItem.style === ButtonStyle.noBackgroundRed) && (mainItem.hovered || mainItem.pressed)
		}
		TextMetrics {
			id: textMetrics
			text: mainItem.text
			font.bold: true
		}
	}
	
	component ButtonImage: EffectImage {
        asynchronous: mainItem.asynchronous
		imageSource: mainItem.icon.source
		imageWidth: mainItem.icon.width
		imageHeight: mainItem.icon.height
        colorizationColor: mainItem.colorizationColor
	}
	
	contentItem: Control.StackView{
		id: stacklayout
		function updateComponent(){
			var item
			var component = mainItem.text.length != 0 && mainItem.icon.source.toString().length != 0
					? imageTextComponent
					: mainItem.text.length != 0
					  ? textComponent
					  : mainItem.icon.source.toString().length != 0
						? imageComponent
						: emptyComponent
			if( stacklayout.depth == 0)
				item = stacklayout.push(component, Control.StackView.Immediate)
			else if( component != stacklayout.get(0))
				item = stacklayout.replace(component, Control.StackView.Immediate)
			if(item){// Workaround for Qt bug : set from the item and not from the contentItem which seems to be lost
				implicitHeight = Qt.binding(function() { return item.implicitHeight})
				implicitWidth = Qt.binding(function() { return item.implicitWidth})
			}
		}
		
		Component.onCompleted: {
			updateComponent()
		}
		
		Connections{
			target: mainItem
			function onTextChanged(){stacklayout.updateComponent()}
			function onIconChanged(){stacklayout.updateComponent()}
		}
		
		Component{
			id: imageTextComponent
			// Workaround for centering the content when its
			// width is smaller than the button width
			Item {
				implicitWidth: content.implicitWidth
				implicitHeight: content.implicitHeight
				RowLayout {
					id: content
					spacing: mainItem.spacing
					anchors.centerIn: parent
					ButtonImage{
						Layout.preferredWidth: mainItem.icon.width
						Layout.preferredHeight: mainItem.icon.height
					}
					ButtonText {
					}
				}
			}
		}
		Component{
			id: textComponent
			ButtonText {
				width: stacklayout.width
				height: stacklayout.height
				// Hack for StackView binding loop
				onImplicitHeightChanged: {implicitHeight}
			}
		}
		Component{
			id: imageComponent
			Item {
				width: stacklayout.width
				height: stacklayout.height
				ButtonImage {
					id: buttonIcon
					anchors.fill: parent
				}
				ButtonImage {
					z: buttonIcon.z + 1
					visible: !mainItem.enabled
					anchors.fill: parent
					colorizationColor: DefaultStyle.grey_0
					opacity: 0.5
				}
			}
		}
		Component{
			id: emptyComponent
			Item {
				width: stacklayout.width
				height: stacklayout.height
			}
		}
	}
	/*
	contentItem: StackLayout {
		id: stacklayout
		currentIndex: mainItem.text.length != 0 && mainItem.icon.source.toString().length != 0
			? 0
			: mainItem.text.length != 0
				? 1
				: mainItem.icon.source.toString().length != 0
					? 2
					: 3
					
		width: mainItem.width
		RowLayout {
			spacing: mainItem.spacing
			ButtonImage{
				Layout.preferredWidth: mainItem.icon.width
				Layout.preferredHeight: mainItem.icon.height
			}
			ButtonText{}
		}
		ButtonText {}
		ButtonImage{}
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}*/
}
