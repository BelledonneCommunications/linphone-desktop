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
	property bool squaredDisplay: false
	
	function appendItem(item){
		console.log("Adding "+item)
		mainLayout.delegateModel.model.append(item)
	/*
		if( bottomRowList.model.count < grid.columns - 1)
			bottomRowList.model.append(item)
		else
			while(bottomRowList.model.count > 0 && tryToAdd(bottomRowList.model.get(0))){
				bottomRowList.model.remove(0,1)
			}*/
	}
	
	function add(item){
		if( !grid.isLayoutWillChanged() || !transitionningTimer.running)
			//grid.model.append(item)
			appendItem(item)
		else
			bufferModels.append(item)
	}
	
	function remove(index){
		console.log("Removing at "+index)
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
	
	/*
	Item{// Spacer
		Layout.fillWidth: true
		Layout.fillHeight: true
	}*/
	GridView{
		id: grid
		property int margin: 10
		property int itemCount: model.count ? model.count :( model.length ? model.length : 0)
		property int columns: 1
		property int rows: 1
		
		function updateLayout(){
			columns = getColumnCount(itemCount)
			rows = getRowCount(itemCount)
		}
		function getColumnCount(itemCount){
			return itemCount > 0 ? Math.sqrt(itemCount-1) + 1  : 1
		}
		function getRowCount(itemCount){
			return columns > 1 ? (itemCount-1) / columns + 1 : 1
		}
		property int computedWidth: (mainLayout.width - grid.margin ) / columns
		property int computedHeight: (mainLayout.height - grid.margin ) / rows 
		cellWidth: ( squaredDisplay ? Math.min(computedWidth, computedHeight) : computedWidth)
		cellHeight: ( squaredDisplay ? Math.min(computedWidth, computedHeight) : computedHeight) 
		
		function isLayoutWillChanged(){
			return columns !== getColumnCount(itemCount+1) || rows !== getRowCount(itemCount+1)
		}
		
		//Layout.fillHeight: true
		//Layout.fillWidth: true
		Layout.preferredWidth: cellWidth * columns
		Layout.preferredHeight: cellHeight * rows
		Layout.alignment: Qt.AlignCenter
		
		interactive: false
		model: DelegateModel{}
		/*
		model: ListModel{}
		//delegate: internalComponent
		delegate: Component{
			Loader{
				property int modelIndex: index
				height: grid.cellHeight-5
				width: grid.cellWidth-5
				sourceComponent: mainLayout.delegate
			}
		}*/
		
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
				ScriptAction {
					script: {
						mainLayout.startTransition()
					}
				}
				ParallelAnimation {
					NumberAnimation { property: "opacity"; to: 0; duration: mainLayout.maxTransitionTime }
					NumberAnimation { properties: "x,y"; to: 0; duration: mainLayout.maxTransitionTime }
				}
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
			console.log("Mosaic "+model+" itemCount: " +itemCount +" => " + (model.count ? " count="+model.count :( model.length ? " length":" no" )))
		}
		
	}/*
	Item{// Spacer
		Layout.fillWidth: true
		Layout.fillHeight: true
	}*/
	/*
	ListView{
		id: bottomRowList
		Layout.preferredWidth: grid.cellWidth * model.count
		Layout.preferredHeight: grid.cellHeight
		Layout.alignment: Qt.AlignCenter
		orientation: Qt.Horizontal
		model: ListModel{}
		
		delegate: Component{
			Loader{
				property int modelIndex: index
				height: grid.cellHeight - 5
				width: grid.cellWidth - 5
				sourceComponent: mainLayout.delegate
			}
		}*/
		/*
		delegate:Rectangle{
			width: grid.cellWidth
			height: grid.cellHeight
			onWidthChanged: console.log(width)
			onHeightChanged: console.log(height)
			color: '#'+ Math.floor(Math.random()*255).toString(16)
										+Math.floor(Math.random()*255).toString(16)
										+Math.floor(Math.random()*255).toString(16)
		}*/
	//}
	
}