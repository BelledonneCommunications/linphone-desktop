import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0
import Common.Styles 1.0

// =============================================================================

ComboBox {
  id: comboBox

  textRole: 'key'

  // ---------------------------------------------------------------------------

  background: Rectangle {
    border {
      color: ComboBoxStyle.background.border.color
      width: ComboBoxStyle.background.border.width
    }

    color: ComboBoxStyle.background.color
    radius: ComboBoxStyle.background.radius

    implicitHeight: ComboBoxStyle.background.height
    implicitWidth: ComboBoxStyle.background.width
  }

  indicator: Icon {
    icon: 'drop_down'
    iconSize: ComboBoxStyle.background.iconSize

    x: comboBox.width - width - comboBox.rightPadding
    y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
  }

  // ---------------------------------------------------------------------------

  delegate: ItemDelegate {
    id: item

    background: Rectangle {
      color: item.hovered
        ? ComboBoxStyle.delegate.color.hovered
        : ComboBoxStyle.delegate.color.normal

      Rectangle {
        anchors.left: parent.left
        color: ComboBoxStyle.delegate.indicator.color

        height: parent.height
        width: ComboBoxStyle.delegate.indicator.width

        visible: item.hovered
      }

      Rectangle {
        anchors.bottom: parent.bottom
        color: ComboBoxStyle.delegate.separator.color

        height: ComboBoxStyle.delegate.separator.height
        width: parent.width

        visible: comboBox.count !== index + 1
      }
    }

    font.bold: comboBox.currentIndex === index
    hoverEnabled: true
    text: key
    width: comboBox.width
  }
}
