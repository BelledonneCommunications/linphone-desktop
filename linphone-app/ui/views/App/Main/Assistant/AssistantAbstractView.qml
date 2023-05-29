import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0

import App.Styles 1.0

// =============================================================================

Item {
	id: view
	
	// ---------------------------------------------------------------------------
	
	property alias mainActionEnabled: mainActionButton.enabled
	property alias mainActionLabel: mainActionButton.text
	property var mainAction
	
	property alias description: description.text
	property alias title: title.text
	
	property bool backEnabled: true
	property bool maximized: false	// Used to stretch content to fit all the view (the title will be set to top)
	
	default property alias _content: content.data
	property alias contentItem: content

	property int decorationHeight: title.implicitHeight + title.anchors.topMargin
									+description.implicitHeight + description.anchors.topMargin
									+content.anchors.topMargin
									+buttons.implicitHeight+AssistantAbstractViewStyle.info.spacing
	
	// ---------------------------------------------------------------------------
	
	//height: (maximized?stack.height:AssistantAbstractViewStyle.content.height)
	//width: (maximized?stack.width:AssistantAbstractViewStyle.content.width)
	anchors.horizontalCenter: maximized || !parent? undefined : parent.horizontalCenter
	anchors.verticalCenter: maximized || !parent? undefined : parent.verticalCenter
	
	// ---------------------------------------------------------------------------
	// Info.
	// ---------------------------------------------------------------------------
	Text {
		id: title
		anchors.top:parent.top
		anchors.topMargin:(visible?AssistantAbstractViewStyle.info.spacing:0)
		anchors.horizontalCenter: parent.horizontalCenter
		color: AssistantAbstractViewStyle.info.title.colorModel.color
		elide: Text.ElideRight
		
		font {
			pointSize: AssistantAbstractViewStyle.info.title.pointSize
			bold: true
		}
		
		horizontalAlignment: Text.AlignHCenter
		width: parent.width
		visible: text.length > 0
		height:(visible?contentHeight:0)
	}
	
	Text {
		id: description
		anchors.top:title.bottom
		anchors.topMargin:(visible?AssistantAbstractViewStyle.info.spacing:0)
		anchors.horizontalCenter: parent.horizontalCenter
		
		color: AssistantAbstractViewStyle.info.description.colorModel.color
		elide: Text.ElideRight
		
		font.pointSize: AssistantAbstractViewStyle.info.description.pointSize
		
		horizontalAlignment: Text.AlignHCenter
		width: parent.width
		
		visible: text.length > 0
		height:(visible?contentHeight:0)
	}
	
	// -------------------------------------------------------------------------
	// Content.
	// -------------------------------------------------------------------------
	
	Item {
		id: content
		anchors.top:description.bottom
		anchors.topMargin:(description.visible || title.visible?AssistantAbstractViewStyle.info.spacing:0)
		anchors.bottom:buttons.top
		anchors.left: parent.left
		anchors.right: parent.right
	}
	
	// ---------------------------------------------------------------------------
	// Nav buttons.
	// ---------------------------------------------------------------------------
	
	Row {
		id: buttons
		
		anchors {
			bottom: parent.bottom
			bottomMargin: AssistantAbstractViewStyle.info.spacing
			horizontalCenter: parent.horizontalCenter
			
		}
		
		spacing: AssistantAbstractViewStyle.buttons.spacing
		
		TextButtonA {
			text: qsTr('back')
			visible: view.backEnabled
			
			onClicked: assistant.popView()
			anchors.verticalCenter: parent.verticalCenter
		}
		
		TextButtonB {
			id: mainActionButton
			
			visible: !!view.mainAction
			
			onClicked: view.mainAction()
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
