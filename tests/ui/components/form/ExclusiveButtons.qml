import QtQuick 2.7

// ===================================================================

Row {
    property int selectedButton: 0
    property variant texts

    signal clicked (int button)

    spacing: 8

    Repeater {
        model: texts
        SmallButton {
            anchors.verticalCenter: parent.verticalCenter
            backgroundColor: selectedButton === index
                ? '#8E8E8E'
                : (button.down
                   ? '#FE5E00'
                   : '#D1D1D1'
                  )
            id: button
            text: modelData

            onClicked: {
                if (selectedButton !== index) {
                    selectedButton = index
                    clicked(index)
                }
            }
        }
    }
}
