import Common 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: (function () {
    console.log('TODO')
  })

  mainActionEnabled: username.text.length &&
    sipDomain.text.length &&
    password.text.length

  mainActionLabel: qsTr('confirmAction')

  title: qsTr('useOtherSipAccountTitle')

  // ---------------------------------------------------------------------------

  Form {
    anchors.fill: parent
    orientation: Qt.Vertical

    FormLine {
      FormGroup {
        label: qsTr('usernameLabel')

        TextField {
          id: username
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('displayNameLabel')

        TextField {}
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('sipDomainLabel')

        TextField {
          id: sipDomain
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('passwordLabel')

        PasswordField {
          id: password
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('transportLabel')

        ExclusiveButtons {
          texts: [ 'UDP', 'TCP', 'TLS' ]
        }
      }
    }
  }
}
