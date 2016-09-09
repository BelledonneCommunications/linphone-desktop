import QtQuick 2.7
import QtQuick.Controls 2.0

// ===================================================================

ComboBox {
    background: Rectangle {
        color: 'transparent'
    }
    id: comboBox
    delegate: ItemDelegate {
        background: Rectangle {
            color: delegate.down
                ? '#FE5E00'
                : (
                    comboBox.currentIndex === index
                        ? '#F0F0F0'
                        : '#FFFFFF'
                )
            opacity: enabled ? 1 : 0.3
        }
        font.weight: comboBox.currentIndex === index
            ? Font.DemiBold
            : Font.Normal
        id: delegate
        text: key || modelData
        width: comboBox.width
    }
}
