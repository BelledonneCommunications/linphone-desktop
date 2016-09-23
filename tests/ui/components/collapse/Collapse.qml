import QtQuick 2.7

import 'qrc:/ui/components/form'
import 'qrc:/ui/style'

// ===================================================================

Item {
    property bool isCollapsed: false

    signal collapsed (bool collapsed)

    function collapse () {
        isCollapsed = !isCollapsed
        collapsed(isCollapsed)
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
        from: isCollapsed ? 0 : 180
        property: 'rotation'
        target: button
        to: isCollapsed ? 180 : 0
    }
}
