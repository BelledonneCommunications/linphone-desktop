import QtTest 1.1

import Linphone 1.0
import Utils 1.0

// =============================================================================

// Check defined properties/methods used in `Notifier.cpp`.
TestCase {
  Notification {
    id: notification
  }

  function test_notificationDataProperty () {
    compare(Utils.isObject(notification.notificationData), true)
  }

  function test_notificationPopupX () {
    compare(Utils.isInteger(notification.popupX), true)
  }

  function test_notificationPopupY () {
    compare(Utils.isInteger(notification.popupY), true)
  }

  function test_notificationPopupHeight () {
    compare(Utils.isInteger(notification.popupHeight), true)
  }

  function test_notificationPopupWidth () {
    compare(Utils.isInteger(notification.popupWidth), true)
  }

  function test_notificationOpenMethod () {
    compare(Utils.isFunction(notification.open), true)
  }

  function test_childWindow () {
    var window = notification.data[0]

    compare(Utils.qmlTypeof(window, 'QQuickWindowQmlImpl'), true)
    compare(window.objectName === '__internalWindow', true)
  }
}
