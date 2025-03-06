import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control

import Linphone

ColumnLayout {
	id: mainItem
	required property list<Item> itemsList
	// Items count is needed when using a repeater for itemsList
	// which is part of the carouselStackLayout children list
	required property int itemsCount
	property int currentIndex: carouselStackLayout.currentIndex
	property var currentItem: carouselButton.itemAt(currentIndex)
    spacing: Math.round(61 * DefaultStyle.dp)

	function goToSlide(index) {
		carouselStackLayout.goToSlideAtIndex(index)
	}

	StackLayout {
		id: carouselStackLayout
		children: mainItem.itemsList
		property int previousIndex: currentIndex
		currentIndex: 0

		function goToSlideAtIndex(index) {
			carouselStackLayout.previousIndex = carouselStackLayout.currentIndex
			carouselStackLayout.currentIndex = index
		}

		onCurrentIndexChanged: {
			var currentItem = children[currentIndex]
			var crossFaderAnim = crossFader.createObject(parent, {fadeInTarget: currentItem, mirrored: (previousIndex > currentIndex)})
			crossFaderAnim.restart()
			mainItem.currentIndex = currentIndex
		}

		Component {
			id: crossFader

			ParallelAnimation {
				id: anim
				property bool mirrored: false
				property Item fadeOutTarget
				property Item fadeInTarget

				NumberAnimation {
					target: fadeInTarget
					property: "opacity"
					from: 0
					to: 1
					duration: 300
				}

				XAnimator {
					target: fadeInTarget
					from: (mirrored ? -1 : 1) * fadeInTarget.width/3.
					to: 0
					duration: 300
					easing.type: Easing.OutCubic
				}
			}
		}
	}

	Item {
		Rectangle {
			id: currentIndicator
            width: Math.round(13 * DefaultStyle.dp)
            height: Math.round(8 * DefaultStyle.dp)
            radius: Math.round(30 * DefaultStyle.dp)
			color: DefaultStyle.main1_500_main
			z: 1
			x: mainItem.currentIndex >= 0 && mainItem.currentItem ? mainItem.currentItem.x - width/2 + mainItem.currentItem.width/2 : 0
			Behavior on x { NumberAnimation {duration: 100}}
		}
		RowLayout {
			id: carouselButtonsLayout
            spacing: Math.round(7.5 * DefaultStyle.dp)
            anchors.leftMargin: Math.round(2.5 * DefaultStyle.dp)
			Repeater {
				id: carouselButton
				model: mainItem.itemsCount
				delegate: Button {
                    Layout.preferredWidth: Math.round(8 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(8 * DefaultStyle.dp)
					topPadding: 0
					bottomPadding: 0
					leftPadding: 0
					rightPadding: 0
					background: Rectangle {
						color: DefaultStyle.main2_200
                        radius: Math.round(30 * DefaultStyle.dp)
						anchors.fill: parent
					}
					onClicked: {
						mainItem.goToSlide(modelData)
					}
				}
			}
			Item{Layout.fillWidth: true}
		}
	}
}
 
