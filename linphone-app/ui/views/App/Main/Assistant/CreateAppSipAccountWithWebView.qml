import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 1.3 // Busy indicator

import Common 1.0
import Linphone 1.0 as Linphone

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
	id: view
	maximized:true
	height: (parent?parent.height:0)
	width: (parent?parent.width:0)
	property string defaultUrl
	property string defaultLogoutUrl
	property string configFilename
	property bool printed : stack.currentItem == view	
	onPrintedChanged: {
		webviewLoader.active = printed
	}
	
	//-------------------------------
	
	property int status : 0	// 0:nothing, -1:error, 1:ok
	property bool newPage : true
	
	
	// ---------------------------------------------------------------------------
	// Menu.
	// ---------------------------------------------------------------------------
// Note : Use opacity and not visibility to allow smooth updating (when moving visibility to true, we could show the old page)
	Component{
		id: webviewComponent
		WebView{
			id:webview
			property bool isLogingOut : true
			state: 'hidden'
			Component.onCompleted: {if(webview.httpUserAgent != undefined) webview.httpUserAgent = Linphone.CoreManager.getUserAgent()	// only available on Qt 5.15 (QtWebView 1.15)
				isLogingOut = true
				webview.url = view.defaultLogoutUrl
			}
			function getData(){// Check if account_infos exists in the page and retrieve data to make/update an account
				if(webview.loading){
					view.status = 0
				}else {
					var js = "(typeof account_infos !== 'undefined'?account_infos:'')";
					webview.runJavaScript(js, function(result) {
						if( result == ''){
							view.status = 0
						}else{
							webview.state = 'hidden'
							reloadTimer.stop();
							console.log("[CreateAccount] SIP : " +result.sip);
							console.log("[CreateAccount] Username : " +result.username);
							console.log("[CreateAccount] Registrar : " +result.registrar_address);
							console.log("[CreateAccount] Domain : " +result.domain);
							if (Linphone.AccountSettingsModel.addOrUpdateAccount( {
																						 sipAddress: result.sip,
																						 serverAddress: result.registrar_address,
																						 configFilename: view.configFilename
																					 })) {
								
								console.log("[CreateAccount] Account created")
								view.status = 1
								Linphone.AccountSettingsModel.setDefaultAccountFromSipAddress("sip:"+result.sip)
							} else {
								console.error("[CreateAccount] Cannot create account. Check logs.")
								view.status = -1
							}
							
						}
					});
				}
			}
	
			Timer {// Check data
				id:reloadTimer
				interval: 1000;
				running: true; repeat: true
				onTriggered: {webview.getData();}
			}
	
			onLoadingChanged: {
				if (loadRequest.errorString)
					console.error("[CreateAccount] error on loading page : " +loadRequest.errorString);
				if(loading){
					view.newPage = true;
				}else if(view.newPage) {
					view.newPage = false;
					webview.runJavaScript("document.querySelector('nav').remove(); document.querySelector('footer').remove();");
				}
				webview.state = (loading || isLogingOut ? 'hidden' : 'showed')
				if(!loading){
					if(isLogingOut){
						isLogingOut = false
						webview.url = view.defaultUrl
					}else{
						reloadTimer.stop();
						webview.getData();
						if(view.status == 0)
							reloadTimer.start();
					}
				}else
					reloadTimer.stop();
			}
			states: [
					State {
						name: 'hidden'
						PropertyChanges { target: webview; opacity: 0 }
					},
					State {
						name: 'showed'
						PropertyChanges { target: webview; opacity: 1 }
					}
				]
				transitions: [
					Transition {
						from: '*'; to: 'showed'
						SequentialAnimation{
							NumberAnimation{ properties: "opacity"; easing.type: Easing.OutBounce; duration: 500 }
						}
					},
					Transition {
						SequentialAnimation{
							NumberAnimation{ properties: "opacity"; duration: 1000 }
						}
					}
				]
		}
	}
	Loader{
		id: webviewLoader
		active: false
		anchors.fill:parent
		sourceComponent: webviewComponent
		
	}

	Rectangle{
		id:statusPage
		anchors.fill:parent
		visible: webviewLoader.item && (webviewLoader.item.loading || webviewLoader.item.isLogingOut || webviewLoader.item.state == 'hidden')
		BusyIndicator{
			id:busy
			anchors.centerIn : parent
			running:true
			width:CreateAppSipAccountStyle.busy.size
			height:CreateAppSipAccountStyle.busy.size
		}

		Icon{
			visible: view.status != 0
			icon: (view.status>0?"chat_read":"chat_error")
			iconSize:busy.width
			anchors.fill:busy
			MouseArea{
				anchors.fill:parent
				onClicked: {
					assistant.popView()
				}
			}
		}
	}
}
