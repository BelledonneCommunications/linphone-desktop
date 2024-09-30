import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp 1.0

Window{
	id: mainItem
	height: 400
	width: 800
	visible: true
	Rectangle{
		anchors.centerIn: parent
		height: 300
		width: 200
		color: 'gray'
		Avatar{
			anchors.centerIn: parent
			height: 100
			width: height
			_address: 'sip:jul@toto.com'
		}
		Loader{
			id: cameraLoader
			anchors.fill: parent
			Timer{
				id: resetTimer
				interval: 1
				onTriggered: {cameraLoader.active=false; cameraLoader.active=true;}
			}
			active: true
			sourceComponent: cameraComponent
		}
		Component{
			id: cameraComponent
			Rectangle{
				height: cameraLoader.height
				width: cameraLoader.width
				color: 'red'
					CameraGui{
					id: cameraItem
					anchors.fill: parent
					visible: isReady
					onVisibleChanged: console.log('Ready?'+visible)
					
					onRequestNewRenderer: {
						console.log("Request new renderer")
						resetTimer.restart()
					}
				}
			}
		}
	}
	
	/*
	Control.StackView{
		id: stackView
		anchors.fill: parent
		initialItem: cameraComponent
		
		Component{
			id: avatarComponent
			Avatar{
			}
		}
		Component{
			id: cameraComponent
			CameraGui{
				id: cameraItem
				onRequestNewRenderer: {
					console.log("Request new renderer")
					stackView.replace(cameraComponent, Control.StackView.Immediate)
					
				}
			}
		}
	}
	*/
}
