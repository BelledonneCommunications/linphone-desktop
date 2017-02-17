import QtQuick 2.7

// Warning: This import is necessary to use the attached property `Screen`.
// See: https://doc-snapshots.qt.io/qt5-5.7/qml-qtquick-window-screen.html
import QtQuick.Window 2.2

import Common 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

DesktopPopup {
  id: notification

  // ---------------------------------------------------------------------------

  property alias notificationHeight: notification.popupHeight
  property int notificationOffset: 0
  property var notificationData: ({})

  readonly property var window: _window
  property var _window

  // ---------------------------------------------------------------------------

  flags: Qt.Popup

  Component.onCompleted: {
    var window = _window = data[0]

    Utils.assert(
      Utils.qmlTypeof(window, 'QQuickWindowQmlImpl'), true,
      'Unable to found `Window` object in `DesktopPopup`.'
    )

    window.x = Qt.binding(function () {
      var screen = window.Screen
      return screen != null
        ? screen.width - window.width - NotificationStyle.margin
        : 0
    })

    window.y = Qt.binding(function () {
      var screen = window.Screen

      if (screen == null) {
        return 0
      }

      var height = screen.desktopAvailableHeight - window.height
      return height - (notificationOffset % height)
    })
  }
}
