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
            function _getAvailableLocales () {
              var locales = []

              App.availableLocales.forEach(function (locale) {
                locales.push({
                  key: Utils.capitalizeFirstLetter(locale.nativeLanguageName),
                  value: locale.name
                })
              })

              return locales.sort(function (a, b) {
                return a > b
              })
            }

            textRole: 'key'
            model: ListModel {}

            Component.onCompleted: {
              var locales = _getAvailableLocales()

              model.append({
                key: qsTr('systemLocale'),
                value: ''
              })
              locales.forEach(function (locale) {
                model.append(locale)
              })

              var locale = App.configLocale
              if (!locale.length) {
                currentIndex = 0
                return
              }

              var value = Qt.locale(locale).name
              var index = Utils.findIndex(locales, function (locale) {
                return locale.value === value
              })

              currentIndex = index != null ? index + 1 : 0
            }

            onActivated: App.configLocale = model.get(index).value
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
  }
}
