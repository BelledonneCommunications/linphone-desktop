import QtQuick 2.7

import Common 1.0

import App.Styles 1.0

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
            model: ListModel {
              ListElement { key: 'English'; value: 0 }
              ListElement { key: 'Français'; value: 1 }
            }
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
            id: savedScreenshotsFolder

            selectFolder: true
          }
        }

        FormGroup {
          label: qsTr('savedVideosLabel')

          FileChooserButton {
            id: savedVideosFolder

            selectFolder: true
          }
        }
      }
    }
  }
}
