import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQml.Models


// =============================================================================
ColumnLayout{
	id: mainLayout
	property alias delegateModel: grid.model
	property alias cellHeight: grid.cellHeight
	property alias cellWidth: grid.cellWidth
	property alias margins: grid.margin
	
	function appendItem(item){
		mainLayout.delegateModel.model.append(item)
	}
	
	function add(item){
		if( !grid.isLayoutWillChanged())
			appendItem(item)
		else
			bufferModels.append(item)
	}
	
	function remove(index){
		if(mainLayout.delegateModel.model.count > index)
			mainLayout.delegateModel.model.remove( index, 1)
	}
	
	function get(index){
		return mainLayout.delegateModel.model.get(index)
	}
	
	function tryToAdd(item){
		if( !grid.isLayoutWillChanged()) {
			appendItem(item)
			return true
		}else
			return false
	}
	
	function clear(){
		if(mainLayout.delegateModel.model.clear) {
			mainLayout.delegateModel.model.clear()
			bufferModels.clear()
		}
	}
	
	
	property int transitionCount : 0
	property var bufferModels : ListModel{}
	
	onWidthChanged: grid.updateLayout()
	onHeightChanged: grid.updateLayout()
	spacing: 0
	
	GridView{
		id: grid
        property real margin: Math.round(10 * DefaultStyle.dp)
		property int itemCount: model.count ? model.count :( model.length ? model.length : 0)
		property int columns: 1
		property int rows: 1
		
		function getBestLayout(itemCount){
			var availableW = mainLayout.width - grid.margin
			var availableH = mainLayout.height - grid.margin
			var bestSize = 0
			var bestC = 1, bestR = 1
			for(var R = 1 ; R <= itemCount ; ++R){
				for(var C = itemCount ; C >= 1 ; --C){
					if( R * C >= itemCount){// This is a good layout candidate
						var estimatedSize = Math.min(availableW / C, availableH / R)
						if(estimatedSize > bestSize	// Size is better
						|| (estimatedSize == bestSize && Math.abs(bestR-bestC) > Math.abs(R - C) )){// Stickers are more homogenized
							bestSize = estimatedSize
							bestC = C
							bestR = R
						}
					}
				}
			}
			return [bestR, bestC]
		}
		
		function updateLayout(){
			var bestLayout = getBestLayout(itemCount)
			if( rows != bestLayout[0])
				rows = bestLayout[0]
			if( columns != bestLayout[1])
				columns = bestLayout[1]
		}
		function updateCells(){
			cellWidth = Math.min(computedWidth, computedHeight)
			cellHeight = Math.min(computedWidth, computedHeight)
		}
		onItemCountChanged: updateLayout()
        property real computedWidth: (mainLayout.width - grid.margin ) / columns
        property real computedHeight: (mainLayout.height - grid.margin ) / rows
		onComputedHeightChanged: Qt.callLater(updateCells)
		onComputedWidthChanged: Qt.callLater(updateCells)
		cellWidth: Math.min(computedWidth, computedHeight)
		cellHeight: Math.min(computedWidth, computedHeight)
		
		function isLayoutWillChanged(){
			var bestLayout = getBestLayout(itemCount+1)
			return rows !== bestLayout[0] || columns !== bestLayout[1]
		}
		
		Layout.preferredWidth: cellWidth * columns
		Layout.preferredHeight: cellHeight * rows
		Layout.alignment: Qt.AlignCenter
		
		interactive: false
		model: DelegateModel{}
		
		onCountChanged: grid.updateLayout()
	}
}
