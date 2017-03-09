import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  id: view

  description: qsTr('createLinphoneSipAccountDescription')
  title: qsTr('createLinphoneSipAccountTitle')

  // ---------------------------------------------------------------------------
  // Create with phone number.
  // ---------------------------------------------------------------------------

  Component {
    id: phoneNumberView

    AssistantAbstractView {
      mainAction: (function () {
        console.log('TODO')
      })

      mainActionEnabled: country.currentIndex !== -1 &&
        phoneNumber.text.length

      mainActionLabel: qsTr('confirmAction')

      title: view.title

      Form {
        anchors.fill: parent
        orientation: Qt.Vertical

        FormLine {
          FormGroup {
            label: qsTr('countryLabel')

            ComboBox {
              id: country
            }
          }
        }

        FormLine {
          FormGroup {
            label: qsTr('phoneNumberLabel')

            TextField {
              id: phoneNumber
            }
          }
        }

        FormLine {
          FormGroup {
            label: qsTr('usernameLabel')

            TextField {}
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Create with email address.
  // ---------------------------------------------------------------------------

  Component {
    id: emailAddressView

    AssistantAbstractView {
      mainAction: (function () {
        console.log('TODO')
      })

      mainActionEnabled: username.text.length
        && email.text.length
        && password.text.length
        && passwordConfirmation.text === password.text

      mainActionLabel: qsTr('confirmAction')

      title: view.title

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
            label: qsTr('emailLabel')

            TextField {
              id: email
            }
          }
        }

        FormLine {
          FormGroup {
            label: qsTr('passwordLabel')

            TextField {
              id: password
            }
          }
        }

        FormLine {
          FormGroup {
            label: qsTr('passwordConfirmationLabel')

            TextField {
              id: passwordConfirmation
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------

  Column {
    anchors.centerIn: parent
    spacing: AssistantCreateLinphoneSipAccountStyle.buttons.spacing
    width: AssistantCreateLinphoneSipAccountStyle.buttons.button.width

    TextButtonA {
      text: qsTr('withPhoneNumber')

      height: AssistantCreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView(phoneNumberView)
    }

    TextButtonA {
      text: qsTr('withEmailAddress')

      height: AssistantCreateLinphoneSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView(emailAddressView)
    }
  }
}
