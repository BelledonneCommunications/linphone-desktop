import QtQuick 2.7

import Common 1.0
import Linphone 1.0

// =============================================================================

AssistantAbstractView {
  mainAction: requestBlock.execute

  mainActionEnabled: username.text.length &&
    sipDomain.text.length &&
    password.text.length

  mainActionLabel: qsTr('confirmAction')

  title: qsTr('useOtherSipAccountTitle')

  // ---------------------------------------------------------------------------

  Column {
    anchors.fill: parent

    Form {
      dealWithErrors: true
      orientation: Qt.Vertical
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('usernameLabel')

          TextField {
            id: username
          }
        }

        FormGroup {
          label: qsTr('displayNameLabel')

          TextField {
            id: displayName
          }
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

          ComboBox {
            id: transport

            model: [ 'UDP', 'TCP', 'TLS', 'DTLS' ]
          }
        }
      }
    }

    RequestBlock {
      id: requestBlock

      action: (function () {
        if (!assistantModel.addOtherSipAccount({
          username: username.text,
          displayName: displayName.text,
          sipDomain: sipDomain.text,
          password: password.text,
          transport: transport.model[transport.currentIndex]
        })) {
          requestBlock.stop(qsTr('addOtherSipAccountError'))
        } else {
          requestBlock.stop('')
          window.setView('Home')
        }
      })

      width: parent.width
    }
  }

  AssistantModel {
    id: assistantModel
  }
}
