import QtQuick 2.7
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0
import Linphone 1.0
import Units 1.0
import UtilsCpp 1.0

import 'qrc:/ui/scripts/Utils/utils.js' as Utils

Item{
	id: mainItem
	property font customFont : SettingsModel.textMessageFont
	signal emojiClicked(var emoji)
	
	width: 500
	height: mainLayout.height
		
	property var emojis:{
		"emoticons": [[0x1F600, 0x1F64F]]
		, "misc": [ [0x1F300, 0x1F5FF],[0x2600, 0x26FF], [0x238C, 0x2426], [0x2440, 0x2449] ]
		, "maps": [ [0x1F680, 0x1F6D7], [0x1F6E0, 0x1F6EC], [0x1F6F0, 0x1F6FC] ]
		, "flags": [ [0x1F1E6, 0x1F1FF] ]
		, "dingbats": [ [0x2700, 0x27B0] ]
		, "picto": [ [0x1F900, 0x1F978], [0x1F980, 0x1F9CB], [0x1F9CD, 0x1F9FF] ]
		, "asian": [ [0x1F018, 0x1F02B], [0x1F030, 0x1F093], [0x1F0A0, 0x1F0AE], [0x1F0B1, 0x1F0BF], [0x1F0C1, 0x1F0CF], [0x1F0D1, 0x1F0F5], [0x1F100, 0x1F10C], [0x1F110, 0x1F16C], [0x1F170, 0x1F1AC], [0x1F1E6, 0x1F202], [0x1F210, 0x1F23B], [0x1F240, 0x1F248], [0x1F250, 0x1F251], [0x1F260, 0x1F264] ]
		, "marks": [ [0x2010, 0x2027], [0x2030, 0x205E], [0x2070, 0x209C], [0x20A0, 0x20BF]] //0x20BF], [0x20D0, 0x20EE] ]
	}
	
	function getArrayLength(iconArray){
		return iconArray[1] - iconArray[0]
	}
	property int maxIndex: {
		var count = 0
		for( var i in emojis){
			for(var j in emojis[i]){
				count += getArrayLength(emojis[i][j])
			}
		}
		console.log("Max items : " +count)
		return count
	}
	function getEmojiCodeInArray(index, iconArray){
		var length = getArrayLength(iconArray)
		if( index < length )
			return [iconArray[0] + index, index];
		else {
			return [-1, index - length]
		}
		
	}
	function getEmojiCodeInMatrix(index, matrix, emojiIndex){
		var result = [-1, index]
		while(result[0]<0 && emojiIndex < matrix.length) result = getEmojiCodeInArray(result[1], matrix[emojiIndex++])
		return result
	}
	
	function getEmojiCode(index){
		var result = [-1, index]
		result = getEmojiCodeInMatrix(result[1], emojis.emoticons, 0)
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.misc[0])
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.maps[0])
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.flags[0])
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.dingbats[0])
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.picto[0])
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.asian[0])
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInArray(result[1], emojis.marks[0])
		else return result[0]
		
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.misc, 1)
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.maps, 1)
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.flags, 1)
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.dingbats, 1)
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.picto, 1)
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.asian, 1)
		else return result[0]
		if(result[0]<0) result = getEmojiCodeInMatrix(result[1], emojis.marks, 1)
		else return result[0]
		
		return result[0]
	}
	MouseArea{
		anchors.fill: parent
		cursorShape: Qt.ArrowCursor
	}
	ColumnLayout{
		id: mainLayout
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 5
		spacing: 0
		Text{
			Layout.bottomMargin: 5
			Layout.fillWidth: true
			//: 'Last used' : Emoji title for last used section.
			text: qsTr('emojisLastUsed')
			property font customFont : SettingsModel.textMessageFont
			font.pointSize: Units.dp * customFont.pointSize
			font.family: customFont.family
			font.weight: Font.Bold
			visible: gridPreferred.model.length > 0
			MouseArea{
				anchors.fill: parent
				onClicked: EmojisSettingsModel.clear()
			}
		}
		GridLayout{
			id: gridPreferred
			Layout.fillWidth: true
			Layout.preferredWidth: parent.width
			Layout.preferredHeight: availableRows * emojiSize
			
			property int emojiSize: EmojiPickerStyle.emojiSize + EmojiPickerStyle.emojiMargin	// emoji + margin. margin is set here in order to avoid the use of spacing. This way, the height computation is easer to get.
			property int availableColumns : width /emojiSize
			property int availableRows : (model.length - 1) / availableColumns + 1
			columns: availableColumns
			columnSpacing: 0
			rowSpacing: 0
			property var model: EmojisSettingsModel.lastUseds// Use this model inderction becaus eof Repeater that don't refresh values when the model change (that comes from EmojiSettingsModel which is a list of int)
			
			onModelChanged: {
				emojisPreferredRepeater.model = 0	// Force reset model
				emojisPreferredRepeater.model = model.length
			}
			Repeater{
				id: emojisPreferredRepeater
				model: parent.length
				Text{
					height: gridPreferred.emojiSize
					width: gridPreferred.emojiSize
					Layout.alignment: Qt.AlignTop | Qt.AlignLeft
					font.pointSize: Units.dp * 20
					font.family: customFont.family
					property int code: gridPreferred.model[index]
					property string stringCodePoint: code >=0 ? String.fromCodePoint(code) : ''
					text: UtilsCpp.encodeTextToQmlRichFormat(stringCodePoint)
					
					textFormat: Text.RichText
					visible: code >= 0
					MouseArea{
						anchors.fill: parent
						onClicked: {console.log("Emoji code : "+code+"(" +parseInt(code, 10).toString(16)+") => "+stringCodePoint);emojiClicked(stringCodePoint)}
					}
				}
			}
			Repeater{// Fill empty spaces if needed
				model: Math.max(gridPreferred.availableColumns - gridPreferred.model.length, 0)
				Item{	height: gridPreferred.emojiSize
					width: gridPreferred.emojiSize
				}
			}
		}
		Text{
			Layout.bottomMargin: 5
			Layout.fillWidth: true
			//: 'All' Emoji title for all items.
			text: qsTr('emojisAll')
			property font customFont : SettingsModel.textMessageFont
			font.pointSize: Units.dp * customFont.pointSize
			font.family: customFont.family
			font.weight: Font.Bold
		}

		GridLayout{
			id: grid
			Layout.fillWidth: true
			Layout.preferredWidth: parent.width
			
			Layout.preferredHeight: availableRows * emojiSize
			
			property int emojiSize: EmojiPickerStyle.emojiSize + EmojiPickerStyle.emojiMargin
			property int availableColumns : width /emojiSize
			property int availableRows : (grid.auxItemDisplayed + grid.auxItemsCount - 1) / availableColumns + 1
			
			property int auxItemDisplayed:0
			property int firstItemDisplayed: 0
			property int auxItemsCount: 160
			
			columns: availableColumns
			columnSpacing: 0
			rowSpacing: 0
			
			Repeater{
				id: emojisRepeater
				model: grid.auxItemsCount	// Repeat prioritized items.
				Text{
					height: grid.emojiSize
					width: grid.emojiSize
					Layout.alignment: Qt.AlignTop | Qt.AlignLeft
					font.pointSize: Units.dp * 20
					font.family: customFont.family
					property int code: mainItem.getEmojiCode(index)
					property string stringCodePoint: code >=0 ? String.fromCodePoint(code) : ''
					text: UtilsCpp.encodeTextToQmlRichFormat(stringCodePoint)
					
					textFormat: Text.RichText
					visible: code >=0 && grid.firstItemDisplayed == grid.auxItemsCount
					Component.onCompleted: ++grid.firstItemDisplayed
					MouseArea{
						anchors.fill: parent
						onClicked: {console.log("Emoji code : "+code+"(" +parseInt(code, 10).toString(16)+") => "+stringCodePoint);
						EmojisSettingsModel.addLastUsed(code);
						emojiClicked(stringCodePoint)}
					}
				}
			}

			Timer{
				id: refreshItems
				repeat: true
				interval: 1000
				running: grid.auxItemDisplayed<mainItem.maxIndex-grid.auxItemsCount
				property int lastCount: 0
				onTriggered: {
					console.log("Loaded emojis : " +(grid.auxItemDisplayed - lastCount))
					lastCount = grid.auxItemDisplayed
				}
			}
// Repeat loader items to load auxillary data without freezing gui or other items.
// Make a Loader of Repeater (to avoid multiple loader) doesn't seems to work (TODO: investigation needed)
			Repeater{
				model: mainItem.maxIndex - grid.auxItemsCount
				Loader{
					active: grid.firstItemDisplayed == grid.auxItemsCount
					Connections{
						target: refreshItems
						onTriggered: if(status === Loader.Ready){
							++grid.auxItemDisplayed
							visible = true
							target = null	// signal optimization : one-call trigger.
						}
					}
					visible: false
					
					sourceComponent:
						Text{
						height: grid.emojiSize
						width: grid.emojiSize
						Layout.alignment: Qt.AlignTop | Qt.AlignLeft
						font.pointSize: Units.dp * 20
						font.family: customFont.family
						property int code: mainItem.getEmojiCode(index+grid.auxItemsCount)
						property string stringCodePoint: code >=0 ? String.fromCodePoint(code) : ''
						text: UtilsCpp.encodeTextToQmlRichFormat(stringCodePoint)
						
						textFormat: Text.RichText
						visible: code >= 0
						MouseArea{
							anchors.fill: parent
							onClicked: {console.log("Emoji code : "+code+"(" +parseInt(code, 10).toString(16)+") => "+stringCodePoint);
							EmojisSettingsModel.addLastUsed(code);
							emojiClicked(stringCodePoint)}
						}
					}
				}
			}
			
		}
	}
}