import QtQuick 2.15
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as Control

import Linphone

ColumnLayout {
	id: mainItem
	required property list<Item> itemsList
	// Items count is needed when using a repeater for itemsList
	// which is part of the carouselStackLayout children list
	required property int itemsCount
	property int currentIndex: carouselStackLayout.currentIndex

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
			width: 13 * DefaultStyle.dp
			height: 8 * DefaultStyle.dp
			radius: 30 * DefaultStyle.dp
			color: DefaultStyle.main1_500_main
			z: 1
			x: mainItem.currentIndex >= 0 && carouselButton.itemAt(mainItem.currentIndex) ? carouselButton.itemAt(mainItem.currentIndex).x : 0
			Behavior on x { NumberAnimation {duration: 100}}
		}
		RowLayout {
			id: carouselButtonsLayout
			spacing: 10 * DefaultStyle.dp
			Repeater {
				id: carouselButton
				model: mainItem.itemsCount
				delegate: Button {
					width: 8 * DefaultStyle.dp
					height: 8 * DefaultStyle.dp
					padding: 0
					background: Rectangle {
						color: DefaultStyle.main2_200
						radius: 30 * DefaultStyle.dp
						width: 8 * DefaultStyle.dp
						height: 8 * DefaultStyle.dp
					}
					onClicked: {
						mainItem.goToSlide(modelData)
					}
				}
			}
		}
	}
}
 
