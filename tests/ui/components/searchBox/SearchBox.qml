import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/popup'

// ===================================================================

Item {
    property alias placeholderText: searchField.placeholderText
    property alias maxMenuHeight: menu.maxMenuHeight

    implicitHeight: searchField.height

    function hideMenu () {
        menu.hide()
        shadow.visible = false
    }

    function showMenu () {
        menu.show()
        shadow.visible = true
    }

    TextField {
        signal searchTextChanged (string text)

        anchors.fill: parent
        background: Rectangle {
            implicitHeight: 30
        }
        id: searchField

        Keys.onEscapePressed: focus = false

        onActiveFocusChanged: {
            // Menu is hidden if `TextField` AND `FocusScope` focus
            // are lost.
            if (activeFocus) {
                showMenu()
            } else if (!scope.activeFocus) {
                hideMenu()
            }
        }
        onTextChanged: searchTextChanged(text)
    }

    // Handle focus from content. (Buttons...)
    FocusScope {
        anchors.top: searchField.bottom
        id: scope
        z: 999 // Menu must be above any component.

        Keys.onEscapePressed: focus = false

        onActiveFocusChanged: !searchField.activeFocus &&
            !activeFocus &&
            hideMenu()

        DropDownMenu {
            id: menu
            width: searchField.width
        }
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
}
