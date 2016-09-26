pragma Singleton
import QtQuick 2.7

import 'qrc:/ui/style/global'

QtObject {
    property QtObject separator: QtObject {
        property int height: 1
        property string color: '#DEDEDE'
    }
}
