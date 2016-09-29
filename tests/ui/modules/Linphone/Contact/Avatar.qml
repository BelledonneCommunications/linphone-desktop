import QtQuick 2.7
import QtGraphicalEffects 1.0

import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

Item {
  property alias image: imageToFilter.source
  property string presence
  property string username

  function _computeInitials () {
    var spaceIndex = username.indexOf(' ')
    var firstLetter = username.charAt(0)

    if (spaceIndex === -1) {
      return firstLetter
    }

    return firstLetter + username.charAt(spaceIndex + 1)
  }

  // Image mask. (Circle)
  Rectangle {
    id: mask

    anchors.fill: parent
    color: AvatarStyle.mask.color
    radius: AvatarStyle.mask.radius
  }

  // Initials.
  Text {
    anchors.centerIn: parent
    color: AvatarStyle.initials.color
    font.pointSize: AvatarStyle.initials.fontSize
    text: _computeInitials()
  }

  Image {
    anchors.fill: parent
    id: imageToFilter
    fillMode: Image.PreserveAspectFit

    // Image must be invisible.
    // The only visible image is the OpacityMask!
    visible: false
  }

  // Avatar.
  OpacityMask {
    anchors.fill: imageToFilter
    maskSource: mask
    source: imageToFilter
  }

  // Presence.
  Icon {
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    height: parent.height / 3
    icon: presence
      ? 'led_' + presence
      : ''
    width: parent.width / 3
  }
}
