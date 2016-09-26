import QtGraphicalEffects 1.0

import 'qrc:/ui/style/components'

// ===================================================================

DropShadow {
    color: PopupStyle.shadow.color
    horizontalOffset: PopupStyle.shadow.horizontalOffset
    radius: PopupStyle.shadow.radius
    samples: PopupStyle.shadow.samples
    verticalOffset: PopupStyle.shadow.verticalOffset
}
