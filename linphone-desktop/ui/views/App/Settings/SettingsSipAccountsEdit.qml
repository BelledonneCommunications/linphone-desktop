import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'SettingsSipAccountsEdit.js' as Logic

// =============================================================================

ConfirmDialog {
  property var account

  height: SettingsSipAccountsEditStyle.height
  width: SettingsSipAccountsEditStyle.width

  // ---------------------------------------------------------------------------

  Component.onCompleted: Logic.initForm(account)

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
          id: sipAddress
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('serverAddressLabel') + '*'

        TextField {
          id: serverAddress
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('registrationDurationLabel')

        NumericField {
          id: registrationDuration
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('transportLabel')

        ComboBox {
          id: transport

          model: [ 'TCP', 'UDP', 'TLS' ]
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('routeLabel')

        TextField {
          id: route
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('contactParamsLabel')

        TextField {
          id: contactParams
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('avpfIntervalLabel')

        NumericField {
          id: avpfInterval
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('registerEnabledLabel')

        Switch {
          id: registerEnabled
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('publishPresenceLabel')

        Switch {
          id: publishPresence
        }
      }
    }

    FormLine {
      FormGroup {
        label: qsTr('avpfEnabledLabel')

        Switch {
          id: avpfEnabled
        }
      }
    }
  }
}
