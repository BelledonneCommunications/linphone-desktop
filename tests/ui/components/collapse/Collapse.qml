import QtQuick 2.7

import 'qrc:/ui/components/form'
import 'qrc:/ui/style'

// ===================================================================
// A simple component to build collapsed item.
// ===================================================================

Item {
    property bool _isCollapsed: false

    signal collapsed (bool collapsed)

    function collapse () {
        _isCollapsed = !_isCollapsed
        collapsed(_isCollapsed)
        rotate.start()
    }

    ActionButton {
        id: button

        anchors.centerIn: parent
        background: CollapseStyle.background
        icon: CollapseStyle.icon
        iconSize: CollapseStyle.iconSize

        onClicked: collapse()
    }

    RotationAnimation {
        id: rotate

        direction: RotationAnimation.Clockwise
        duration: CollapseStyle.animationDuration
        from: _isCollapsed ? 0 : 180
        property: 'rotation'
        target: button
        to: _isCollapsed ? 180 : 0
    }
}
