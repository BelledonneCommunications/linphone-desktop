import QtQuick 2.7
import QtGraphicalEffects 1.0

import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Item {
  property alias image: imageToFilter.source
  property alias presenceLevel: presenceLevel.level
  property string username

  property var _initialsRegex: /^\s*([^\s]+)(?:\s+([^\s]+))?/

  function _computeInitials () {
    var result = username.match(_initialsRegex)

    Utils.assert(
      result != null,
      'Unable to get initials of: \'' + username + '\''
    )

    return result[1].charAt(0).toUpperCase() +
      (
        result[2] != null
          ? result[2].charAt(0).toUpperCase()
          : ''
      )
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
  PresenceLevel {
    id: presenceLevel

    anchors.bottom: parent.bottom
    anchors.right: parent.right
    height: parent.height / 3
    width: parent.width / 3
  }
}
