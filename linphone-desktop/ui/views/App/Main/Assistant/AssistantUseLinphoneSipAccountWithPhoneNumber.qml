import Common 1.0

// =============================================================================

Form {
  property bool mainActionEnabled: country.currentIndex !== -1 && phoneNumber.text

  dealWithErrors: true
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
}
