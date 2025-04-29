import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import QtQml
import Linphone
import 'qrc:/qt/qml/Linphone/view/Style/buttonStyle.js' as ButtonStyle

Control.Button {
	id: mainItem
	property int capitalization
	property var style
	property color color: style?.color?.normal || DefaultStyle.main1_500_main
	property color hoveredColor: style?.color?.hovered || Qt.darker(color, 1.05)
    property color pressedColor: style?.color?.pressed || Qt.darker(color, 1.1)
    property color checkedColor: style?.color?.checked || style?.color?.pressed || Qt.darker(color, 1.1)
    property color textColor: style?.text?.normal || DefaultStyle.grey_0
	property color hoveredTextColor: style?.text?.hovered || Qt.darker(textColor, 1.05)
	property color pressedTextColor: style?.text?.pressed || Qt.darker(textColor, 1.1)
	property color borderColor: style?.borderColor || "transparent"
	ToolTip.visible: hovered && ToolTip.text != ""
	ToolTip.delay: 1000
	property color disabledFilterColor: color.hslLightness > 0.5
		? DefaultStyle.grey_0
		: DefaultStyle.grey_400
    property real textSize: Math.round(18 * DefaultStyle.dp)
    property real textWeight: Typography.b1.weight
	property var textHAlignment: Text.AlignHCenter
    property real radius: Math.round(48 * DefaultStyle.dp)
	property bool underline: false
	property bool hasNavigationFocus: enabled && (activeFocus  || hovered)
	property bool shadowEnabled: false
	property var contentImageColor: style?.image?.normal || DefaultStyle.main2_600
	property var hoveredImageColor: style?.image?.pressed || Qt.darker(contentImageColor, 1.05)
	property var checkedImageColor: style?.image?.checked || Qt.darker(contentImageColor, 1.1)
	property var pressedImageColor: style?.image?.pressed || Qt.darker(contentImageColor, 1.1)
    property bool asynchronous: false
    spacing: Math.round(5 * DefaultStyle.dp)
	hoverEnabled: enabled
	activeFocusOnTab: true
	icon.source: style?.iconSource || ""
	MouseArea {
		id: mouseArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
		acceptedButtons: Qt.NoButton
	}
	
	background: Loader{
		asynchronous: mainItem.asynchronous
		anchors.fill: parent
		
		sourceComponent: Item {
			Rectangle {
				id: buttonBackground
				anchors.fill: parent
                color: mainItem.checkable && mainItem.checked
                    ? mainItem.checkedColor || mainItem.pressedColor
                    : mainItem.pressed
                        ? mainItem.pressedColor
                        : mainItem.hovered || mainItem.hasNavigationFocus
                            ? mainItem.hoveredColor
                            : mainItem.color
				radius: mainItem.radius
				border.color: mainItem.borderColor
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
		maximumLineCount: 1
        color: mainItem.checkable && mainItem.checked
            ? mainItem.checkedColor || mainItem.pressedColor
            : mainItem.pressed
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
			bold: mainItem.style === ButtonStyle.noBackground && (mainItem.hovered || mainItem.pressed)
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
        colorizationColor: mainItem.checkable && mainItem.checked
            ? mainItem.checkedImageColor || mainItem.checkedColor || mainItem.pressedColor
            : mainItem.pressed
                ? mainItem.pressedImageColor
                : mainItem.hovered
                    ? mainItem.hoveredImageColor
                    : mainItem.contentImageColor
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
			ButtonImage{
				width: stacklayout.width
				height: stacklayout.height
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
