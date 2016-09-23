import QtQuick 2.0

// ===================================================================
// Helper to handle button click outside a component.
// ===================================================================

Item {
    property var mouseArea

    signal pressed

    function createMouseArea () {
        if (mouseArea == null) {
            mouseArea = builder.createObject(this)
        }

        mouseArea.parent = (function () {
            // Search root.
            var p = item

            while (p.parent != null) {
                p = p.parent
            }

            return p
        })()
    }

    function deleteMouseArea () {
        if (mouseArea != null) {
            mouseArea.destroy()
            mouseArea = null
        }
    }

    function isInItem (point) {
        return (
            point.x >= item.x &&
            point.y >= item.y &&
            point.x <= item.x + item.width &&
            point.y <= item.y + item.height
        )
    }

    id: item

    onEnabledChanged: {
        deleteMouseArea()

        if (enabled) {
            createMouseArea()
        }
    }

    Component {
        id: builder

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            z: 9999999999 // Ugly! But it's necessary in some cases...

            onPressed: {
                // Propagate event.
                mouse.accepted = false

                if (!isInItem(
                    mapToItem(item.parent, mouse.x, mouse.y)
                )) {
                    // Outside!!!
                    item.pressed()
                }
            }
        }
    }

    // It's necessary to use a `enabled` variable.
    // See: http://doc.qt.io/qt-5/qml-qtqml-component.html#completed-signal
    //
    // The creation order of components in a view is undefined,
    // so the mouse area mustt be created only when `enabled == true`.
    //
    // In the first view render, `enabled` must equal false.
    Component.onCompleted: enabled && createMouseArea()
    Component.onDestruction: deleteMouseArea()
}
