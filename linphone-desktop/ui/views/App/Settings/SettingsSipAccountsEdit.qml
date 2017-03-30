import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

ConfirmDialog {
  property var account

  height: 500
  width: 600

  // ---------------------------------------------------------------------------

  Form {
    anchors {
      left: parent.left
      leftMargin: ManageAccountsStyle.leftMargin
      right: parent.right
      rightMargin: ManageAccountsStyle.rightMargin
    }

    FormLine {
      FormGroup {
        label: qsTr('sipAddressLabel') + '*'

        TextField {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('serverAddressLabel') + '*'

        TextField {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('registrationDurationLabel') + '*'

        TextField {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('transportLabel') + '*'

        ComboBox {
          model: [ 'TCP', 'UDP', 'TLS' ]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('routeLabel')

        TextField {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('contactParamsLabel')

        TextField {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('registerLabel')

        Switch {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('publishPresenceLabel')

        Switch {

        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('enableAvpfLabel')

        Switch {

        }
      }
    }
  }
}
