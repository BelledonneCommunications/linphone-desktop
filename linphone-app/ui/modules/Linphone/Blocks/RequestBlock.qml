import QtQuick 2.7

import Common 1.0
import Common.Styles 1.0
import Linphone.Styles 1.0

// =============================================================================

Column {
	id: block
	
	property var action
	
	property bool loading: false
	
	// ----------------------------------------------------------------------------
	
	function start () {
		block.loading = true
		action()
	}
	function execute () {
		action()
	}
	function setText(txt){
		errorBlock.text = txt
	}
	
	
	function stop (error) {
		errorBlock.text = error
		block.loading = false
	}
	
	// ----------------------------------------------------------------------------
	
	TextEdit {
		id: errorBlock
		readOnly: true
		selectByMouse: true
		
		color: RequestBlockStyle.error.colorModel.color
		
		font {
			italic: true
			pointSize: RequestBlockStyle.error.pointSize
		}
		
		height: visible ? undefined : 0
		width: parent.width
		
		horizontalAlignment: Text.AlignHCenter
		padding: RequestBlockStyle.error.padding
		wrapMode: Text.WordWrap
		
		visible: errorBlock.text != ''
	}
	
	BusyIndicator {
		id: busy
		anchors {
			horizontalCenter: parent.horizontalCenter
		}
		color: BusyIndicatorStyle.alternateColor.color
		height: visible ? RequestBlockStyle.loadingIndicator.height : 0
		width: RequestBlockStyle.loadingIndicator.width
		
		running: block.loading
	}
}
