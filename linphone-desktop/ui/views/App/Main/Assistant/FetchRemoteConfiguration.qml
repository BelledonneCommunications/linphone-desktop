import Common 1.0
import Linphone 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: (function () {
    App.restart()
  })

  mainActionEnabled: url.text.length > 0
  mainActionLabel: qsTr('confirmAction')

  title: qsTr('fetchRemoteConfigurationTitle')

  // ---------------------------------------------------------------------------

  Form {
    anchors.fill: parent
    orientation: Qt.Vertical

    FormLine {
      FormGroup {
        label: qsTr('urlLabel')

        TextField {
          id: url
        }
      }
    }
  }
}
