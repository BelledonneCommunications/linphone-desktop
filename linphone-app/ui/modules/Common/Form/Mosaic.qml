import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import QtQml.Models 2.12

import Common 1.0
import Common.Styles 1.0

// =============================================================================
ColumnLayout{
	id: mainLayout
	property alias delegateModel: grid.model
	property alias cellHeight: grid.cellHeight
	property alias cellWidth: grid.cellWidth
	
	function appendItem(item){
		mainLayout.delegateModel.model.append(item)
	}
	
	function add(item){
		if( !grid.isLayoutWillChanged() || !transitionningTimer.running)
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
		if( !grid.isLayoutWillChanged() || !transitionningTimer.running) {
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
	property int maxTransitionTime: 250
	Timer{
		id: transitionningTimer
		running: false
		interval: maxTransitionTime + 5
		onTriggered: updateBuffers()
	}
	function startTransition(){
		transitionningTimer.restart()
	}
	function updateBuffers(){
		while(bufferModels.count > 0 && tryToAdd(bufferModels.get(0))){
			bufferModels.remove(0,1)
		}
	}
	onWidthChanged: grid.updateLayout()
	onHeightChanged: grid.updateLayout()
	GridView{
		id: grid
		property int margin: 10
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
						if(estimatedSize > bestSize){
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
		property int computedWidth: (mainLayout.width - grid.margin ) / columns
		property int computedHeight: (mainLayout.height - grid.margin ) / rows 
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
		
		//-------------------				ANIMATIONS
		property Transition defaultTransition: Transition {
			SequentialAnimation {
				ScriptAction {
					script: {
						mainLayout.startTransition()
					}
				}
				ParallelAnimation {
					NumberAnimation { properties: "x,y"; duration: mainLayout.maxTransitionTime }
				}
			}
		}
		
		add: Transition {
			SequentialAnimation {
				ScriptAction {
					script: {
						mainLayout.startTransition()
					}
				}
				ParallelAnimation {
					NumberAnimation { property: "opacity"; from: 0; duration: mainLayout.maxTransitionTime }
					NumberAnimation { properties: "x,y"; from: 0; duration: mainLayout.maxTransitionTime; easing.type: Easing.OutBounce }
				}
			}
		}
		
		addDisplaced: defaultTransition
		displaced: defaultTransition
		move: defaultTransition
		moveDisplaced: defaultTransition
		remove: Transition {
			SequentialAnimation {
				PropertyAction { target: grid; property: "GridView.delayRemove"; value: true }
				ScriptAction {
					script: {
						mainLayout.startTransition()
					}
				}
				ParallelAnimation {
					NumberAnimation { property: "opacity"; to: 0; duration: mainLayout.maxTransitionTime }
					NumberAnimation { properties: "x,y"; to: 0; duration: mainLayout.maxTransitionTime }
				}
				PropertyAction { target: grid; property: "GridView.delayRemove"; value: false }
			}
		}
		removeDisplaced: defaultTransition
		populate:defaultTransition
		
		Timer{	// if cell sizes change while adding/removing an item the animation will not end at the right position.
			id: updateLayoutDelay
			interval: mainLayout.maxTransitionTime
			onTriggered: grid.updateLayout()
		}
		onItemCountChanged: {
			updateLayoutDelay.restart()
		}
	}
}