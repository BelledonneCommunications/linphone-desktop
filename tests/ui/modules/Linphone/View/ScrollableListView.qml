import QtQuick 2.7
import QtQuick.Controls 2.0

import Linphone 1.0

// ===================================================================

ListView {
  ScrollBar.vertical: ForceScrollBar { }
  boundsBehavior: Flickable.StopAtBounds
  clip: true
  highlightRangeMode: ListView.ApplyRange
  spacing: 0
}
