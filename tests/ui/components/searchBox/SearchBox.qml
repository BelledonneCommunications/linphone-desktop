import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/invertedMouseArea'
import 'qrc:/ui/components/popup'

// ===================================================================

Item {
    property alias placeholderText: searchField.placeholderText
    property alias maxMenuHeight: menu.maxMenuHeight

    signal menuClosed ()
    signal menuOpened ()
    signal searchTextChanged (string text)

    implicitHeight: searchField.height

    function hideMenu () {
        menu.hide()
        shadow.visible = false
        searchField.focus = false
        menuClosed()
    }

    function showMenu () {
        menu.show()
        shadow.visible = true
        menuOpened()
    }

    Item {
        implicitHeight: searchField.height + menu.height
        width: parent.width

        TextField {
            background: Rectangle {
                implicitHeight: 30
            }
            id: searchField
            width: parent.width

            Keys.onEscapePressed: hideMenu()

            onActiveFocusChanged: activeFocus && showMenu()
            onTextChanged: searchTextChanged(text)
        }

        DropDownMenu {
            anchors.top: searchField.bottom
            id: menu
            width: searchField.width
            z: 999 // Menu must be above any component.

            Keys.onEscapePressed: hideMenu()
        }

        DropShadow {
            anchors.fill: searchField
            color: "#80000000"
            horizontalOffset: 2
            id: shadow
            radius: 8.0
            samples: 15
            source: searchField
            verticalOffset: 2
            visible: false
        }

        InvertedMouseArea {
            enabled: menu.visible
            height: parent.height
            parent: parent
            width: parent.width

            onPressed: hideMenu()
        }
    }
}
