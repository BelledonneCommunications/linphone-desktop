pragma Singleton
import QtQuick 2.7

QtObject {
    property int buttonsAreaHeight: 60
    property int buttonsSpacing: 20
    property int leftMargin: 50
    property int rightMargin: 50

    property QtObject description: QtObject {
        property int fontSize: 12
        property int height: 90
        property int minHeight: 25
    }

    property QtObject confirm: QtObject {
        property int height: 150
        property int width: 370
    }
}
