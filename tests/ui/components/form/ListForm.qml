import QtQuick 2.7
import QtQuick.Layouts 1.3

RowLayout {
    readonly property int lineHeight: 30

    property alias title: text.text

    spacing: 0

    RowLayout {
        Layout.alignment: Qt.AlignTop
        Layout.preferredHeight: lineHeight
        spacing: 20

        // Add item in list.
        ActionButton {
            Layout.preferredHeight: 16
            Layout.preferredWidth: 16
            onClicked: {
                console.log(valuesModel.get(valuesModel.count - 1).$value.length)

                if (valuesModel.count === 0 ||
                    valuesModel.get(valuesModel.count - 1).$value.length !== 0
                   ) {
                    valuesModel.append({ $value: '' })
                }
            }
        }

        // List title.
        Text {
            Layout.preferredWidth: 130
            id: text
        }
    }

    // Content list.
    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: values.count * lineHeight
        id: values
        interactive: false

        model: ListModel {
            id: valuesModel

            ListElement { $value: 'toto' }
            ListElement { $value: 'abc' }
            ListElement { $value: 'machin' }
            ListElement { $value: 'bidule' }
            ListElement { $value: 'truc' }
        }

        delegate: Item {
            implicitHeight: textEdit.height
            width: parent.width

            Rectangle {
                color: textEdit.focus ? '#E6E6E6' : 'transparent'
                id: background
                implicitHeight: textEdit.height
                implicitWidth: textEdit.contentWidth + textEdit.padding * 2
            }

            Text {
                anchors.fill: textEdit
                color: '#5A585B'
                font.italic: true
                padding: textEdit.padding
                text: textEdit.text.length === 0 && !textEdit.focus
                    ? qsTr('fillPlaceholder')
                    : ''
                verticalAlignment: Text.AlignVCenter
            }

            TextEdit {
                color: focus ? '#000000' : '#5A585B'
                font.bold: !focus
                height: lineHeight
                id: textEdit
                padding: 10
                selectByMouse: true
                text: $value
                verticalAlignment: TextEdit.AlignVCenter
                width: parent.width

                // To handle editingFinished, it's necessary to set
                // focus on another component.
                Keys.onReturnPressed: parent.forceActiveFocus()

                onEditingFinished: {
                    if (text.length === 0) {
                        valuesModel.remove(index)
                    }

                    // Hack: The edition is finished but the focus
                    // can be set.
                    focus = false
                }
            }
        }
    }
}
