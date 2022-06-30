import QtQuick 2.7 as QtQuick
import QtQuick.Controls 2.2

import Common.Styles 1.0


QtQuick.Text {
	id: mainItem
	property bool computeFitWidth: false	// Avoid doing computations if not needed
	property int fitWidth: 0
	
	// Fit Width computation
	onTextChanged:{
		if(computeFitWidth) {
			var lines = text.split('\n')
			var totalWidth = 0
			for(var index in lines){
				metrics.text = lines[index]
				if( totalWidth < metrics.width)
					totalWidth = metrics.width
			 }
			 fitWidth = totalWidth
		}
	}
	QtQuick.TextMetrics{
		id: metrics
		font: mainItem.font
	}
//-----------------------------------
}
