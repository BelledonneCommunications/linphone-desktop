import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================
// A simple component to build collapsed item.
// ===================================================================

Item {
    property bool _collapsed: false

    signal collapsed (bool collapsed)

    function collapse () {
        _collapsed = !_collapsed
        collapsed(_collapsed)
        rotate.start()
    }

    function isCollapsed () {
        return _collapsed
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
        from: _collapsed ? 0 : 180
        property: 'rotation'
        target: button
        to: _collapsed ? 180 : 0
    }
}
