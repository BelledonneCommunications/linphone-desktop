import QtQuick 2.7
import QtWebView 1.15

import Common 1.0

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
  description: qsTr('createAppSipAccountDescription')
  title: qsTr('createAppSipAccountTitle').replace('%1', Qt.application.name.toUpperCase())
  maximized:true

  // ---------------------------------------------------------------------------
  // Menu.
  // ---------------------------------------------------------------------------
  
	WebView{
		anchors.fill:parent
		httpUserAgent: 'Linphone Desktop'
		//url:'https://www.whatismybrowser.com/detect/what-is-my-user-agent'
		url: 'https://subscribe.linphone.org/register'
		onLoadingChanged: {
				   if (loadRequest.errorString)
					   console.error(loadRequest.errorString);
		}
	}
/*
  Column {
    anchors.centerIn: parent
    spacing: CreateAppSipAccountStyle.buttons.spacing
    width: CreateAppSipAccountStyle.buttons.button.width

    TextButtonA {
      text: qsTr('withPhoneNumber')

      height: CreateAppSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('CreateAppSipAccountWithPhoneNumber')
    }

    TextButtonA {
      text: qsTr('withEmailAddress')

      height: CreateAppSipAccountStyle.buttons.button.height
      width: parent.width

      onClicked: assistant.pushView('CreateAppSipAccountWithEmail')
    }
  }*/
}
