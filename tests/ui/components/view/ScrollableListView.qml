import QtQuick 2.7
import QtQuick.Controls 2.0

import 'qrc:/ui/components/scrollBar'

// ===================================================================

ListView {
    ScrollBar.vertical: ForceScrollBar { }
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    highlightRangeMode: ListView.ApplyRange
    spacing: 0
}
