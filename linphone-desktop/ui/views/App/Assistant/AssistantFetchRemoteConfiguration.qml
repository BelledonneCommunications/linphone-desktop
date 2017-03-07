import Common 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: (function () {
    console.log('TODO')
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
