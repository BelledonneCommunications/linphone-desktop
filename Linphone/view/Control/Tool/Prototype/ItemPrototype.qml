import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0

Rectangle{
	id: mainItem
	property Component component1: comp1
	property Component component2: comp2
	property bool step: false
	color: 'black'
	onStepChanged: {
		stack.replace(step ? component1 : component2)
	}
	Timer{
		id: delay
		interval: 1000
		onTriggered: mainItem.step = !mainItem.step
		repeat: true
		running: true
	}
	Control.StackView{
		id: stack
		anchors.fill: parent
		/*
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.rightMargin: parent.width/2
		anchors.left: parent.left
		anchors.leftMargin: parent.width/2
		anchors.bottom: parent.bottom*/
		initialItem : Rectangle{width: 100
			height: width
			color: 'orange'}
	}
	Component{
		id: comp1
		Rectangle{
			width: 100
			height: width
			color: 'red'
		}
	}
	
	Component{
		id: comp2
		Rectangle{
			width: 100
			height: width
			color: 'green'
		}
	}
}
