import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Effects
import QtQuick.Layouts
import Linphone

Control.Button {
	id: mainItem
	property int capitalization
	property QtObject style
	property color color: style ? style.color.normal : DefaultStyle.main1_500_main
	readonly property color pressedColor: style && style.color.pressed || Qt.darker(color, 1.3)
	readonly property color hoveredColor: style && style.color.hovered || Qt.darker(color, 1.1)
	property color textColor: style && style.text.normal || DefaultStyle.grey_0
	property color pressedTextColor: style && style.text.pressed || textColor
	property color borderColor: style && style.borderColor || "transparent"
	property bool inversedColors: false
	property int textSize: 18 * DefaultStyle.dp
	property int textWeight: 600 * DefaultStyle.dp
	property var textHAlignment: Text.AlignHCenter
	property int radius: 48 * DefaultStyle.dp
	property bool underline: false
	property bool hasNavigationFocus: enabled && (activeFocus  || hovered)
	property var contentImageColor: style && style.image.normal || DefaultStyle.main2_600
	property var pressedImageColor: style && style.image.pressed || DefaultStyle.main2_600
	property bool asynchronous: true
	hoverEnabled: true
	activeFocusOnTab: true
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
				color: mainItem.pressed
					? mainItem.pressedColor
					: mainItem.hovered || mainItem.hasNavigationFocus
						? mainItem.hoveredColor
						: mainItem.color
				radius: mainItem.radius
				border.color: mainItem.borderColor
			}
			Rectangle {
				id: disableShadow
				color: "white"
				opacity: 0.2
				visible: !mainItem.enabled
			}
			MultiEffect {
				enabled: mainItem.hasNavigationFocus
				anchors.fill: buttonBackground
				source: buttonBackground
				visible:  mainItem.hasNavigationFocus
				// Crash : https://bugreports.qt.io/browse/QTBUG-124730
				shadowEnabled: mainItem.hasNavigationFocus
				shadowColor: DefaultStyle.grey_1000
				shadowBlur: 0.1
				shadowOpacity: mainItem.shadowEnabled ? 0.5 : 0.0
			}
		}
	}
	
	component ButtonText: Text {
		id: buttonText
		horizontalAlignment: mainItem.textHAlignment
		verticalAlignment: Text.AlignVCenter
		width: textMetrics.advanceWidth
		wrapMode: Text.WrapAnywhere
		text: mainItem.text
		maximumLineCount: 1
		color: pressed
			? mainItem.pressedTextColor
			: mainItem.textColor
		font {
			pixelSize: mainItem.textSize
			weight: mainItem.textWeight
			family: DefaultStyle.defaultFont
			capitalization: mainItem.capitalization
			underline: mainItem.underline
			bold: mainItem.font.bold
		}
		TextMetrics {
			id: textMetrics
			text: mainItem.text
		}
	}
	
	component ButtonImage: EffectImage {
		imageSource: mainItem.icon.source
		imageWidth: mainItem.icon.width
		imageHeight: mainItem.icon.height
		colorizationColor: mainItem.pressed ? mainItem.pressedImageColor : mainItem.contentImageColor
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
