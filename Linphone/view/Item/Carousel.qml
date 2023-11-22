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
	property bool prevButtonVisible: true
	property bool nextButtonVisible: true

	function goToSlide(index) {
		carouselStackLayout.goToSlideAtIndex(index)
	}

	StackLayout {
		id: carouselStackLayout
		children: mainItem.itemsList
		property int previousIndex: currentIndex

		function goToSlideAtIndex(index) {
			carouselStackLayout.previousIndex = carouselStackLayout.currentIndex;
			carouselStackLayout.currentIndex = index;
		}

		Component.onCompleted: {
			// The animation is not working until the slide
			// has been displayed once
			for (var i = 0; i < mainItem.itemsCount; ++i) {
				// const newObject = Qt.createQmlObject(mainItem.itemsList[i], carouselStackLayout);
				// mainItem.itemsList[i].createObject(carouselStackLayout)
				// carouselStackLayout.append(itemsList[i])
				var button = carouselButton.createObject(carouselButtonsLayout, {slideIndex: i, stackLayout: carouselStackLayout})
				button.buttonClicked.connect(goToSlideAtIndex)
				currentIndex = i
			}
			currentIndex = 0
			previousIndex = currentIndex
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
	RowLayout {
		id: carouselButtonsLayout
		Layout.topMargin: 20
		Layout.bottomMargin: 20

		Component {
			id: carouselButton
			Control.Button {
				property int slideIndex
				property var stackLayout
				signal buttonClicked(int index)

				background: Rectangle {
					color: stackLayout.currentIndex == slideIndex ? DefaultStyle.main1_500_main : DefaultStyle.carouselLightGrayColor
					radius: 15
					width: stackLayout.currentIndex == slideIndex ? 11 : 8
					height: 8
					Behavior on width { NumberAnimation {duration: 100}}
				}
				onClicked: {
					buttonClicked(slideIndex)
				}
			}
		}
	}
}
 
