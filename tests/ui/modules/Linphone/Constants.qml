pragma Singleton
import QtQuick 2.7

QtObject {
    property int zPopup: 999
    property int zMax: 999999

    property QtObject colors: QtObject {
        property string a: 'transparent'
        property string b: '#5E5E5F' // Pressed toolbar.
        property string c: '#C5C5C5' // Released toolbar.

        property string d: '#5A585B' // Text color.

        property string e: '#DEDEDE' // Timeline separator

        property string f: '#808080' // Popup shadow.

        property string g: '#8E8E8E' // MenuEntry Normal.
        property string h: '#707070' // MenuEntry Hovered.
        property string i: '#FE5E00' // MenuEntry Pressed.
        property string j: '#434343' // MenuEntry Selected.

        property string k: '#FFFFFF' // Text color.
    }
}
