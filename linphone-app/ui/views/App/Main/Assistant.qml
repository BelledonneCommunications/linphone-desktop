import QtQuick 2.7
import QtQuick.Window 2.2

import Utils 1.0

import Common 1.0
import App.Styles 1.0

// =============================================================================

Item {
	id: assistant
	// ---------------------------------------------------------------------------
	
	Rectangle {
		anchors.fill: parent
		color: AssistantStyle.colorModel.color
	}
	function pushView (view, properties) {
		stack.pushView(view, properties)
	}
	
	function getView (index) {
		return stack.getView(index)
	}
	
	function popView () {
		stack.popView()
	}
	// ---------------------------------------------------------------------------
	
	StackView {
		id: stack
		anchors.fill: parent
		
		viewsPath: 'qrc:/ui/views/App/Main/Assistant/'
		initialItem: viewsPath + 'AssistantHome.qml'
		
		onExit:window.setView('Home')
	}
}
