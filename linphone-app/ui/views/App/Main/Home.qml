import QtQuick 2.7

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

import App.Styles 1.0

// =============================================================================

Rectangle {
  color: HomeStyle.colorModel.color

  // TODO: Remove me when smart tooltip will be available.
  Component {
    Item {
      property var i18n: [
        QT_TR_NOOP('showTooltips'),
        QT_TR_NOOP('howToDescription'),
        QT_TR_NOOP('howToTitle')
      ]
    }
  }

  ListView {
    anchors.horizontalCenter: parent.horizontalCenter
    boundsBehavior: Flickable.StopAtBounds
    clip: true
    orientation: ListView.Horizontal
    spacing: HomeStyle.spacing

    height: parent.height
    
    width: {
		var itemCount = 0;
		for(var i = 0 ; i < count ; ++i)
			if(model[i].$visible)
				++itemCount;
      var width = CardBlockStyle.width * itemCount + (itemCount - 1) * spacing
      return parent.width < width ? parent.width : width
    }

    model: [{
        $component: 'button',
        $componentText: qsTr('inviteButton'),
        $description: qsTr('inviteDescription'),
        $view: 'InviteFriends',
        $icon: 'home_invite_friends',
        $title: qsTr('inviteTitle'),
        $visible: SettingsModel.getShowHomeInviteButton()
      },{
        $component: 'button',
        $componentText: qsTr('assistantButton'),
        $description: qsTr('accountAssistantDescription'),
        $icon: 'home_account_assistant',
        $title: qsTr('accountAssistantTitle'),
        $view: 'Assistant',
        $visible: true
      }]

    delegate: CardBlock {
      anchors.verticalCenter: parent.verticalCenter

      description: modelData.$description.replace('%1', Utils.capitalizeFirstLetter(Qt.application.name))
      icon: modelData.$icon
      title: modelData.$title.replace('%1', Qt.application.name.toUpperCase())
      visible: modelData.$visible
		
      Loader {
        Component {
          id: button

          TextButtonB {
            text: modelData.$componentText
            onClicked: window.setView(modelData.$view)
          }
        }

        Component {
          id: checkBox

          CheckBoxText {
            text: modelData.$componentText
          }
        }

        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: modelData.$component === 'button' ? button : checkBox
      }
    }
  }
}
