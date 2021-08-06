import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

// =============================================================================

Item {
  id: avatar

  // ---------------------------------------------------------------------------

  property alias presenceLevel: presenceLevelIcon.level
  property color backgroundColor: AvatarStyle.backgroundColor
  property color foregroundColor: 'transparent'
  property string username
  property var image

  property var _initialsRegex: /^\s*([^\s\.]+)(?:[\s\.]+([^\s\.]+))?/
  
  //onPresenceLevelChanged: console.log(Presence.getPresenceLevelIconName(presenceLevel)+' => '+username)

  // ---------------------------------------------------------------------------

  function isLoaded () {
    return roundedImage.status === Image.Ready
  }

  function _computeInitials () {
    var result = username.match(_initialsRegex)

    if (!result) {
      return ''
    }

    return result[1].charAt(0).toUpperCase() + (
      result[2] != null
        ? result[2].charAt(0).toUpperCase()
        : ''
    )
  }

  // ---------------------------------------------------------------------------

  RoundedImage {
    id: roundedImage

    anchors.fill: parent
    backgroundColor: avatar.backgroundColor
    foregroundColor: avatar.foregroundColor
    source: avatar.image || ''
  }

  Text {
    anchors.centerIn: parent
    color: AvatarStyle.initials.color
    font.pointSize: {
      var width

      if (parent.width > 0) {
        width = parent.width / AvatarStyle.initials.ratio
      }

      return AvatarStyle.initials.pointSize * (width || 1)
    }

    text: _computeInitials()
    visible: roundedImage.status !== Image.Ready
  }

  PresenceLevel {
    id: presenceLevelIcon

    anchors {
      bottom: parent.bottom
      right: parent.right
    }

    height: parent.height / 4
    width: parent.width / 4
  }
}
