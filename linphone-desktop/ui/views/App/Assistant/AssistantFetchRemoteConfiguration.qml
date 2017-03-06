import Common 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: (function () {
    console.log('TODO')
  })

  mainActionEnabled: url.text.length > 0
  mainActionLabel: qsTr('confirmAction')

  Form {
    anchors.fill: parent
    orientation: Qt.Vertical
    title: qsTr('fetchRemoteConfigurationTitle')

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
