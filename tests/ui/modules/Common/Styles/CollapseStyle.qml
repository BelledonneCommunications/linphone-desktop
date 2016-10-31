pragma Singleton
import QtQuick 2.7

// ===================================================================

QtObject {
  property int animationDuration: 200
  property int iconSize: 14

  property Rectangle background: Rectangle {
    // Do not use `Colors` singleton.
    // Collapse uses an icon without background color.
    color: 'transparent'
  }
}
