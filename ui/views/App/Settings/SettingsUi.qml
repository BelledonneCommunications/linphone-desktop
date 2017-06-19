import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Utils 1.0

import App.Styles 1.0

import 'SettingsUi.js' as Logic

// =============================================================================

TabContainer {
  Column {
    spacing: SettingsWindowStyle.forms.spacing
    width: parent.width

    // -------------------------------------------------------------------------
    // Languages.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('languagesTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('languagesLabel')

          ComboBox {
            textRole: 'key'

            Component.onCompleted: {
              var locales = Logic.getAvailableLocales()
              model = locales

              var locale = App.configLocale
              if (!locale.length) {
                currentIndex = 0
                return
              }

              var value = Qt.locale(locale).name
              currentIndex = Number(Utils.findIndex(locales, function (locale) {
                return locale.value === value
              }))
            }

            onActivated: Logic.setLocale(model[index].value)
          }
        }
      }
    }

    // -------------------------------------------------------------------------
    // Paths.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('pathsTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('savedScreenshotsLabel')

          FileChooserButton {
            selectedFile: SettingsModel.savedScreenshotsFolder
            selectFolder: true

            onAccepted: SettingsModel.savedScreenshotsFolder = selectedFile
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('savedVideosLabel')

          FileChooserButton {
            selectedFile: SettingsModel.savedVideosFolder
            selectFolder: true

            onAccepted: SettingsModel.savedVideosFolder = selectedFile
          }
        }
      }

      FormLine {
        FormGroup {
          label: qsTr('downloadLabel')

          FileChooserButton {
            selectedFile: SettingsModel.downloadFolder
            selectFolder: true

            onAccepted: SettingsModel.downloadFolder = selectedFile
          }
        }
      }

      FormEmptyLine {}
    }

    TextButtonB {
      anchors.right: parent.right
      text: qsTr('cleanAvatars')

      onClicked: Logic.cleanAvatars()
    }

    // -------------------------------------------------------------------------
    // Other.
    // -------------------------------------------------------------------------

    Form {
      title: qsTr('otherTitle')
      width: parent.width

      FormLine {
        FormGroup {
          label: qsTr('exitOnCloseLabel')

          Switch {
            id: autoAnswer

            checked: SettingsModel.exitOnClose

            onClicked: SettingsModel.exitOnClose = !checked
          }
        }
      }
    }
  }
}
