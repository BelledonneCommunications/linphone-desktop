import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import LinphoneUtils 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

Row {
  signal entryClicked(string sipAddress)
  
  readonly property var _sipAddressObserver: SipAddressesModel.getSipAddressObserver($historyEntry.sipAddress, '')
  
  property string _type: {
    var status = $historyEntry.status

    if (status === HistoryModel.CallStatusSuccess) {
      if (!$historyEntry.isStart) {
        return 'ended_call'
      }
      return $historyEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
    }
    if (status === HistoryModel.CallStatusDeclined) {
      return $historyEntry.isOutgoing ? 'declined_outgoing_call' : 'declined_incoming_call'
    }
    if (status === HistoryModel.CallStatusMissed) {
      return $historyEntry.isOutgoing ? 'missed_outgoing_call' : 'missed_incoming_call'
    }
    if (status === HistoryModel.CallStatusAborted) {
      return $historyEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
    }
    if (status === HistoryModel.CallStatusEarlyAborted) {
      return $historyEntry.isOutgoing ? 'missed_outgoing_call' : 'missed_incoming_call'
    }
    if (status === HistoryModel.CallStatusAcceptedElsewhere) {
      return $historyEntry.isOutgoing ? 'outgoing_call' : 'incoming_call'
    }
    if (status === HistoryModel.CallStatusDeclinedElsewhere) {
      return $historyEntry.isOutgoing ? 'declined_outgoing_call' : 'declined_incoming_call'
    }

    return 'unknown_call_event'
  }

  height: HistoryStyle.entry.lineHeight
  spacing: HistoryStyle.entry.message.extraContent.spacing

  Icon {
    height: parent.height
    icon: _type
    iconSize: HistoryStyle.entry.event.iconSize
    width: HistoryStyle.entry.metaWidth
  }

  Text {
    Component {
      // Never created.
      // Private data for `lupdate`.
      Item {
        property var i18n: [
          QT_TR_NOOP('declinedIncomingCall'),
          QT_TR_NOOP('declinedOutgoingCall'),
          QT_TR_NOOP('endedCall'),
          QT_TR_NOOP('incomingCall'),
          QT_TR_NOOP('missedIncomingCall'),
          QT_TR_NOOP('missedOutgoingCall'),
          QT_TR_NOOP('outgoingCall')
        ]
      }
    }

    color: HistoryStyle.entry.event.text.color
    font {
      bold: true
      pointSize: HistoryStyle.entry.event.text.pointSize
    }
    height: parent.height
    text: qsTr(Utils.snakeToCamel(_type)) +' - '
    verticalAlignment: Text.AlignVCenter
  }
  Text {
    color: HistoryStyle.entry.event.text.color
    font {
      bold: true
      pointSize: HistoryStyle.entry.event.text.pointSize
    }
    height: parent.height
    text: LinphoneUtils.getContactUsername(_sipAddressObserver)
    verticalAlignment: Text.AlignVCenter
    MouseArea{
        anchors.fill:parent
        onClicked:entryClicked($historyEntry.sipAddress)
    }
  }
  ActionButton {
    height: HistoryStyle.entry.lineHeight
    icon: 'delete'
    iconSize: HistoryStyle.entry.deleteIconSize
    visible: isHoverEntry()

    onClicked: removeEntry()
  }
}
