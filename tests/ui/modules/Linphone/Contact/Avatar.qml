import QtQuick 2.7
import QtGraphicalEffects 1.0

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Item {
  id: avatar

  property alias image: roundedImage.source
  property alias presenceLevel: presenceLevel.level
  property color backgroundColor: AvatarStyle.backgroundColor
  property string username

  property var _initialsRegex: /^\s*([^\s\.]+)(?:[\s\.]+([^\s\.]+))?/

  // -----------------------------------------------------------------

  function _computeInitials () {
    var result = username.match(_initialsRegex)

    Utils.assert(
      result != null,
      'Unable to get initials of: \'' + username + '\''
    )

    return result[1].charAt(0).toUpperCase() + (
      result[2] != null
        ? result[2].charAt(0).toUpperCase()
        : ''
    )
  }

  // -----------------------------------------------------------------

  RoundedImage {
    id: roundedImage

    anchors.fill: parent
    backgroundColor: avatar.backgroundColor
  }

  Text {
    anchors.centerIn: parent
    color: AvatarStyle.initials.color
    font.pointSize: {
      var width

      if (parent.width > 0) {
        width = parent.width / AvatarStyle.initials.ratio
      }

      return AvatarStyle.initials.fontSize * (width || 1)
    }

    text: _computeInitials()
    visible: roundedImage.status !== Image.Ready
  }

  PresenceLevel {
    id: presenceLevel

    anchors {
      bottom: parent.bottom
      right: parent.right
    }

    height: parent.height / 4
    width: parent.width / 4
  }
}
