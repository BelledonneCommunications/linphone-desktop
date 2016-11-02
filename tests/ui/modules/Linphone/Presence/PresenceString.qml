import QtQuick 2.7

import Linphone 1.0
import Linphone.Styles 1.0

// ===================================================================

Text {
  property int status: -1

  function _getStatusString () {
    switch (status) {
      case Presence.Online:
        return qsTr('presenceOnline')
      case Presence.BeRightBack:
        return qsTr('presenceBeRightBack')
      case Presence.Away:
        return qsTr('presenceAway')
      case Presence.OnThePhone:
        return qsTr('presenceOnThePhone')
      case Presence.OutToLunch:
        return qsTr('presenceOutToLunch')
      case Presence.DoNotDisturb:
        return qsTr('presenceDoNotDisturb')
      case Presence.Moved:
        return qsTr('presenceMoved')
      case Presence.UsingAnotherMessagingService:
        return qsTr('presenceUsingAnotherMessagingService')
      case Presence.Offline:
        return qsTr('presenceOffline')
      default:
        return qsTr('presenceUnknown')
    }
  }

  color: PresenceStringStyle.color
  elide: Text.ElideRight
  font.pointSize: PresenceStringStyle.fontSize
  text: _getStatusString()
}
