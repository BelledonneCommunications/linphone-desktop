pragma Singleton
import QtQuick 2.7

QtObject {
    property int zPopup: 999
    property int zMax: 999999

    // TODO: Mutualize similar colors.
    property QtObject colors: QtObject {
        property string a: 'transparent'
        property string b: '#5E5E5F'
        property string c: '#C5C5C5'
        property string d: '#5A585B'
        property string e: '#DEDEDE'
        property string f: '#808080'
    }
}
