/*
 * MIT License

Copyright (c) 2023 AmirHosseinCH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// import EmojiModel

ColumnLayout {
    id: mainItem
    property var editor
    property EmojiModel model: EmojiModel {
        id: emojiModel
        iconsPath: "image://emoji/emojiSvgs/"
        iconsType: '.svg'
    }
    property var categories: ['Smileys & Emotion', 'People & Body', 'Animals & Nature',
        'Food & Drink', 'Activities', 'Travel & Places', 'Objects', 'Symbols', 'Flags']
    property var searchModel: ListModel {}
    property bool searchMode: false
    property int skinColor: -1
    
    signal emojiClicked(string emoji)

    function changeSkinColor(index) {
        if (index !== skinColors.current) {
            skinColors.itemAt(skinColors.current + 1).scale = 0.6
            skinColors.itemAt(index + 1).scale = 1
            skinColors.current = index
            mainItem.skinColor = index
        }
    }
    function refreshSearchModel() {
        searchModel.clear()
        var searchResult = model.search(searchField.text, skinColor)
        for (var i = 0; i < searchResult.length; ++i) {
            searchModel.append({path: searchResult[i]})
        }
    }
    RowLayout {
        id: categoriesRow
        Layout.preferredWidth: parent.width - Utils.getSizeWithScreenRatio(15)
        Layout.preferredHeight: Utils.getSizeWithScreenRatio(35)
        Layout.leftMargin: Utils.getSizeWithScreenRatio(5)
        Layout.alignment: Qt.AlignCenter
        spacing: Utils.getSizeWithScreenRatio(searchField.widthSize > 0 ? 7 : 17)
        clip: true
        Image {
            id: searchIcon
            source: "image://emoji/icons/search.svg"
            sourceSize: Qt.size(Utils.getSizeWithScreenRatio(21),Utils.getSizeWithScreenRatio(21))
            visible: !mainItem.searchMode
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mainItem.searchMode = true
                    searchField.widthSize = categoriesRow.width - Utils.getSizeWithScreenRatio(25)
                    list.model = 1
                    searchField.focus = true
                }
            }
        }
        Image {
            id: closeIcon
            source: "image://emoji/icons/close.svg"
            sourceSize: Qt.size(Utils.getSizeWithScreenRatio(21),Utils.getSizeWithScreenRatio(21))
            visible: mainItem.searchMode
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mainItem.searchMode = false
                    searchField.widthSize = 0
                    list.model = mainItem.categories
                    searchField.clear()
                }
            }
        }
        TextField {
            id: searchField
            property int widthSize: 0
            Layout.preferredWidth: widthSize
            Layout.preferredHeight: Utils.getSizeWithScreenRatio(28)
            visible: widthSize > 0 ? true : false
            placeholderText: 'Search Emoji'
            Behavior on widthSize {
                NumberAnimation {
                    duration: 400
                }
            }
            background: Rectangle {
                radius: Utils.getSizeWithScreenRatio(10)
                border.color: DefaultStyle.main1_500_main
            }
            onTextChanged: {
                text.length > 0 ? mainItem.refreshSearchModel() : mainItem.searchModel.clear()
            }
        }
        Repeater {
            id: cateIcons
            property var blackSvg: ['emoji-smiley.svg', 'emoji-people.svg', 'emoji-animal.svg', 'emoji-food.svg',
                'emoji-activity.svg', 'emoji-travel.svg', 'emoji-object.svg', 'emoji-symbol.svg', 'emoji-flag.svg']
            property var blueSvg: ['emoji-smiley-blue.svg', 'emoji-people-blue.svg', 'emoji-animal-blue.svg',
                'emoji-food-blue.svg', 'emoji-activity-blue.svg', 'emoji-travel-blue.svg', 'emoji-object-blue.svg',
                'emoji-symbol-blue.svg', 'emoji-flag-blue.svg']
            property int current: 0
            model: 9
            delegate: Image {
                id: icon
                source: "image://emoji/icons/" + cateIcons.blackSvg[index]
                sourceSize: Qt.size(Utils.getSizeWithScreenRatio(20),Utils.getSizeWithScreenRatio(20))
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (cateIcons.current !== index) {
                            icon.source = "image://emoji/icons/" + cateIcons.blueSvg[index]
                            cateIcons.itemAt(cateIcons.current).source = "image://emoji/icons/" + cateIcons.blackSvg[cateIcons.current]
                            cateIcons.current = index
                        }
                        list.positionViewAtIndex(index, ListView.Beginning)
                    }
                }
            }
            Component.onCompleted: {
                itemAt(0).source = "image://emoji/icons/" + cateIcons.blueSvg[0]
            }
        }
    }
    ListView {
        id: list
        width: mainItem.width
        height: Utils.getSizeWithScreenRatio(250)
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: mainItem.categories
        spacing: Utils.getSizeWithScreenRatio(30)
        topMargin: Utils.getSizeWithScreenRatio(7)
        bottomMargin: Utils.getSizeWithScreenRatio(7)
        leftMargin: Utils.getSizeWithScreenRatio(12)
        clip: true
        delegate: GridLayout {
            id: grid
            property string category: mainItem.searchMode ? 'Search Result' : modelData
            property int columnCount: Math.round(list.width / Utils.getSizeWithScreenRatio(50))
            property int sc: grid.category === 'People & Body' ? mainItem.skinColor : -1
            columns: columnCount
            width: list.width
            columnSpacing: Utils.getSizeWithScreenRatio(5)
            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(20)
                text: grid.category
                color: Qt.rgba(0, 0, 0, 0.5)
                font.pixelSize: Utils.getSizeWithScreenRatio(15)
                horizontalAlignment: Text.AlignLeft
                leftPadding: Utils.getSizeWithScreenRatio(6)
                Layout.columnSpan: grid.columnCount != 0 ? grid.columnCount : 1
                Layout.bottomMargin: Utils.getSizeWithScreenRatio(8)
            }
            Repeater {
                model: mainItem.searchMode ? mainItem.searchModel : mainItem.model.count(grid.category)
                delegate: Rectangle  {
                    property alias es: emojiSvg
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(40)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(40)
                    radius: Utils.getSizeWithScreenRatio(40)
                    color: mouseArea.containsMouse ? '#e6e6e6' : '#ffffff'
                    Image {
                        id: emojiSvg
                        source: mainItem.searchMode ? path : mainItem.model.path(grid.category, index, grid.sc)
                        sourceSize: Qt.size(Utils.getSizeWithScreenRatio(30),Utils.getSizeWithScreenRatio(30))
                        anchors.centerIn: parent
                        asynchronous: true
                    }
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        property string imageUrl: emojiSvg.source
                        onClicked: {
                            var emojiInFont = Utils.codepointFromFilename(UtilsCpp.getFilename(emojiSvg.source))
                            if (mainItem.editor) mainItem.editor.insert(mainItem.editor.cursorPosition, emojiInFont)
                            mainItem.emojiClicked(emojiInFont)
                        }
                    }
                }
            }
        }
        onContentYChanged: {
            var index = list.indexAt(0, contentY + 15)
            if (index !== -1 && index !== cateIcons.current) {
                cateIcons.itemAt(index).source = "image://emoji/icons/" + cateIcons.blueSvg[index]
                cateIcons.itemAt(cateIcons.current).source = "image://emoji/icons/" + cateIcons.blackSvg[cateIcons.current]
                cateIcons.current = index
            }
        }
    }
    RowLayout {
        Layout.preferredHeight: Utils.getSizeWithScreenRatio(35)
        Layout.alignment: Qt.AlignCenter
        spacing: 10
        Repeater {
            id: skinColors
            property var colors: ['#ffb84d', '#ffdab3', '#d2a479', '#ac7139', '#734b26', '#26190d']
            property int current: -1
            model: 6
            delegate: Rectangle {
                id: colorRect
                Layout.preferredWidth: Utils.getSizeWithScreenRatio(30)
                Layout.preferredHeight: Utils.getSizeWithScreenRatio(30)
                Layout.bottomMargin: Utils.getSizeWithScreenRatio(3)
                radius: Utils.getSizeWithScreenRatio(30)
                scale: 0.65
                color: skinColors.colors[index]
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mainItem.changeSkinColor(index - 1)
                        if (mainItem.searchMode) {
                            mainItem.refreshSearchModel();
                        }
                    }
                }
            }
            Component.onCompleted: {
                itemAt(0).scale = 1
            }
        }
    }
}
