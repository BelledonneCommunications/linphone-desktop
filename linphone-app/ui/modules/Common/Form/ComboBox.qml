import QtQuick 2.7
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.3

import Common 1.0
import Common.Styles 1.0

import 'ComboBox.js' as Logic

// =============================================================================

Controls.ComboBox {
  id: comboBox

  // ---------------------------------------------------------------------------

  property var iconRole

  // ---------------------------------------------------------------------------

  background: Rectangle {
    border {
      color: ComboBoxStyle.background.border.color
      width: ComboBoxStyle.background.border.width
    }

    color: comboBox.enabled
      ? ComboBoxStyle.background.color.normal
      : ComboBoxStyle.background.color.readOnly

    radius: ComboBoxStyle.background.radius

    implicitHeight: ComboBoxStyle.background.height
    implicitWidth: ComboBoxStyle.background.width
  }

  // ---------------------------------------------------------------------------

  contentItem: Item {
    height: comboBox.height
    width: comboBox.width

    RowLayout {
      anchors {
        fill: parent
        leftMargin: ComboBoxStyle.contentItem.leftMargin
      }

      spacing: ComboBoxStyle.contentItem.spacing

      Icon {
        icon: Logic.getSelectedEntryIcon()
        iconSize: ComboBoxStyle.contentItem.iconSize

        visible: icon.length > 0
      }

      Text {
        Layout.fillWidth: true

        color: ComboBoxStyle.contentItem.text.color
        elide: Text.ElideRight

        font.pointSize: ComboBoxStyle.contentItem.text.pointSize
        rightPadding: comboBox.indicator.width + comboBox.spacing

        text: Logic.getSelectedEntryText()
      }
    }
  }

  // ---------------------------------------------------------------------------

  indicator: Icon {
    icon: 'drop_down'
    iconSize: ComboBoxStyle.background.iconSize

    x: comboBox.width - width - comboBox.rightPadding
    y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
  }

  // ---------------------------------------------------------------------------

  delegate: CommonItemDelegate {
    id: item

    container: comboBox
    flattenedModel: comboBox.textRole.length &&
      (typeof modelData !== 'undefined' ? modelData : model)
    itemIcon: Logic.getItemIcon(item)
    width: comboBox.width
  }
}
