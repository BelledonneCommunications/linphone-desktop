import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0

import Common 1.0
import Common.Styles 1.0

// =============================================================================
ColumnLayout{
	id: mainLayout
	property Component delegate
	
	function appendItem(item){
		grid.model.append(item)
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
		if(grid.model.count > index)
			grid.model.remove( index, 1)
	}
	
	function get(index){
		return grid.model.get(index)
	}
	
	function tryToAdd(item){
		if( !grid.isLayoutWillChanged() || !transitionningTimer.running) {
			appendItem(item)
			return true
		}else
			return false
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
	
	
	
	GridView{
		id: grid
		
		property int itemCount: model.count ? model.count :( model.length ? model.length : 0)
		property int columns: getColumnCount(itemCount)
		property int rows: getRowCount(itemCount)
		
		function getColumnCount(itemCount){
			return itemCount > 0 ? Math.sqrt(itemCount-1) + 1  : 1
		}
		function getRowCount(itemCount){
			return columns > 1 ? (itemCount-1) / columns + 1 : 1
		}
		
		cellWidth: (mainLayout.width - 5 ) / columns
		cellHeight: (mainLayout.height - 5 ) / rows 
		
		function isLayoutWillChanged(){
			return columns !== getColumnCount(itemCount+1) || rows !== getRowCount(itemCount+1)
		}
		
		Layout.fillHeight: true
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignCenter
		
		interactive: false
		model: ListModel{}
		//delegate: internalComponent
		delegate: Component{
			Loader{
				property int modelIndex: index
				height: grid.cellHeight-5
				width: grid.cellWidth-5
				sourceComponent: mainLayout.delegate
			}
		}
		
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
		
	}
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