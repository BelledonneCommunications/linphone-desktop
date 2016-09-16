import QtQuick 2.7
import QtQuick.Layouts 1.3

import 'qrc:/ui/components/image'

Message {
    backgroundColor: '#E4E4E4'
    id: message

    Item {
        height: 30
        width: 30

        // TODO: Success and re-send icon.
        Icon {
            anchors.centerIn: parent
            icon: 'valid'
            iconSize: 16
        }
    }
}
