import QtQuick 2.7
import QtGraphicalEffects 1.0

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// ===================================================================

Item {
  property alias image: roundedImage.source
  property alias presenceLevel: presenceLevel.level
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
  }

  RoundedImage {
    id: roundedImage

    anchors.fill: parent
    backgroundColor: AvatarStyle.backgroundColor
  }

  PresenceLevel {
    id: presenceLevel

    anchors.bottom: parent.bottom
    anchors.right: parent.right
    height: parent.height / 3
    width: parent.width / 3
  }
}
