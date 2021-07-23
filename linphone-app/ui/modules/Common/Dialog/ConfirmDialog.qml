import Common 1.0
import Common.Styles 1.0

// =============================================================================
// A dialog with OK/Cancel buttons.
// =============================================================================

DialogPlus {
  buttons: [
    TextButtonA {
      text: qsTr('cancel')

      onClicked: exit(0)
    },
    TextButtonB {
      text: qsTr('confirm')

      onClicked: exit(1)
    }
  ]

  buttonsAlignment: Qt.AlignCenter

  height: DialogStyle.confirmDialog.height
  width: DialogStyle.confirmDialog.width
}
