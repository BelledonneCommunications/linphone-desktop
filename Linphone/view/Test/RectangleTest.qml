import QtQuick

Rectangle {
	function genRandomColor(){
		return '#'+ Math.floor(Math.random()*255).toString(16)
										+Math.floor(Math.random()*255).toString(16)
										+Math.floor(Math.random()*255).toString(16)
	}

	color: genRandomColor() //"blue"
	opacity: 0.2
	border.color: genRandomColor() //"red"
	border.width: 2
}
