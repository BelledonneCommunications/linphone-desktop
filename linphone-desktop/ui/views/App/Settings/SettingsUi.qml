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

    // TODO

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
