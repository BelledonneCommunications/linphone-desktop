import QtQuick 2.7

// =============================================================================

Grid {
  property var call

  // ---------------------------------------------------------------------------

  columns: 3

  Repeater {
    model: [{
      text: '1',
      icon: 'answering_machine'
    }, {
      text: '2'
    },{
      text: '3'
    }, {
      text: '4'
    }, {
      text: '5'
    }, {
      text: '6'
    }, {
      text: '7'
    }, {
      text: '8'
    }, {
      text: '9'
    }, {
      text: '*'
    }, {
      text: '0',
      icon: 'plus'
    }, {
      text: '#'
    }]

    TelKeypadButton {
      icon: modelData.icon
      text: modelData.text

      onClicked: console.log('TODO')
    }
  }
}
