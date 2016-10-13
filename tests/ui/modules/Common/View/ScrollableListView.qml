import QtQuick 2.7
import QtQuick.Controls 2.0

import Common 1.0

// ===================================================================

ListView {
  ScrollBar.vertical: ForceScrollBar { }
  boundsBehavior: Flickable.StopAtBounds
  clip: true
  spacing: 0
}
