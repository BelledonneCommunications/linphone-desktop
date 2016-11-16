import QtTest 1.1

import Linphone 1.0
import Utils 1.0

// ===================================================================

// Check defined properties/methods used in `Notifier.cpp`.
TestCase {
  Notification {
    id: notification
  }

  function test_notificationHeightProperty () {
    compare(Utils.isInteger(notification.notificationHeight), true)
 }

  function test_notificationOffsetProperty () {
    compare(Utils.isInteger(notification.notificationOffset), true)
  }

  function test_notificationShowMethod () {
    compare(Utils.isFunction(notification.show), true)
  }
}
