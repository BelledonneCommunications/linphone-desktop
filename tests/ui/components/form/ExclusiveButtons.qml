import QtQuick 2.7

// ===================================================================

Row {
    property alias text1: button1.text
    property alias text2: button2.text

    property bool button1IsSelected: true

    signal buttonChanged (int button)

    spacing: 8

    SmallButton {
        anchors.verticalCenter: parent.verticalCenter
        backgroundColor: button1IsSelected
            ? '#8E8E8E'
            : (button1.down
               ? '#FE5E00'
               : '#D1D1D1'
              )
        id: button1
        onClicked: {
            if (!button1IsSelected) {
                button1IsSelected = true
                buttonChanged(1)
            }
        }
    }

    SmallButton {
        anchors.verticalCenter: parent.verticalCenter
        backgroundColor: !button1IsSelected
            ? '#8E8E8E'
            : (button2.down
               ? '#FE5E00'
               : '#D1D1D1'
              )
        id: button2
        onClicked: {
            if (button1IsSelected) {
                button1IsSelected = false
                buttonChanged(2)
            }
        }
    }
}
