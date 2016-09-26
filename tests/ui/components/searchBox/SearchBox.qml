import QtQuick 2.7
import QtQuick.Controls 2.0

import AppStyle 1.0
import ComponentsStyle 1.0

import 'qrc:/ui/components/invertedMouseArea'
import 'qrc:/ui/components/popup'

// ===================================================================

Item {
    property alias placeholderText: searchField.placeholderText
    property alias maxMenuHeight: menu.maxMenuHeight

    signal menuClosed ()
    signal menuOpened ()
    signal searchTextChanged (string text)

    function _hideMenu () {
        menu.hide()
        shadow.visible = false
        searchField.focus = false

        menuClosed()
    }

    function _showMenu () {
        menu.show()
        shadow.visible = true

        menuOpened()
    }

    implicitHeight: searchField.height

    Item {
        implicitHeight: searchField.height + menu.height
        width: parent.width

        TextField {
            id: searchField

            background: SearchBoxStyle.searchFieldBackground
            width: parent.width

            Keys.onEscapePressed: _hideMenu()

            onActiveFocusChanged: activeFocus && _showMenu()
            onTextChanged: searchTextChanged(text)
        }

        DropDownMenu {
            id: menu

            anchors.top: searchField.bottom
            width: searchField.width
            z: Constants.zPopup

            Keys.onEscapePressed: _hideMenu()
        }

        InvertedMouseArea {
            enabled: menu.visible
            height: parent.height
            parent: parent
            width: parent.width

            onPressed: _hideMenu()
        }

        PopupShadow {
            id: shadow

            anchors.fill: searchField
            source: searchField
            visible: false
        }
    }
}
