import QtQuick 2.7
import QtWebView 1.1
import QtQuick.Controls 1.3 // Busy indicator

import Common 1.0
import Linphone 1.0 as Linphone

import App.Styles 1.0

// =============================================================================

AssistantAbstractView {
	maximized:true
	height: (parent?parent.height:0)
	width: (parent?parent.width:0)
	property alias url : webview.url
	// ---------------------------------------------------------------------------
	// Menu.
	// ---------------------------------------------------------------------------
// Note : Use opcity and not visibility to allow smooth updating (when moving visibility to true, we could show the old page)
	WebView{
		id:webview
		property int status : 0	// 0:nothing, -1:error, 1:ok
		property bool newPage : true
		anchors.fill:parent
		Component.onCompleted: if(httpUserAgent) httpUserAgent = Linphone.App.getUserAgent()	// only available on Qt 5.15 (QtWebView 1.15)
		function getData(){// Check if account_infos exists in the page and retrieve data to make/update an account
			if(webview.loading){
				webview.status = 0
			}else {
				var js = "(typeof account_infos !== 'undefined'?account_infos:'')";
				webview.runJavaScript(js, function(result) {
					if( result == ''){
						webview.status = 0
					}else{
						webview.opacity=0
						reloadTimer.stop();
						console.log(result);
						console.log("[CreateAccount] SIP : " +result.sip);
						console.log("[CreateAccount] Username : " +result.username);
						console.log("[CreateAccount] Registrar : " +result.registrar_address);
						console.log("[CreateAccount] Domain : " +result.domain);
						if (Linphone.AccountSettingsModel.addOrUpdateProxyConfig( {
																					 sipAddress: result.sip,
																					 serverAddress: result.registrar_address
																				 })) {
							
							console.log("[CreateAccount] Account created")
							webview.status = 1
							Linphone.AccountSettingsModel.setDefaultProxyConfigFromSipAddress("sip:"+result.sip)
						} else {
							console.error("[CreateAccount] Cannot create account. Check logs.")
							webview.status = -1
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
			if(loading)
				newPage = true;
			else if(newPage) {
				newPage = false;
				webview.runJavaScript("document.querySelector('nav').remove(); document.querySelector('footer').remove();");
			}
			webview.opacity= (loading?0:1)
			if(!loading){
				reloadTimer.stop();
				webview.getData();
				if(webview.status == 0)
					reloadTimer.start();
			}else
				reloadTimer.stop();
		}
	}

	Rectangle{
		id:statusPage
		anchors.fill:parent
		visible: webview.loading || webview.opacity==0
		BusyIndicator{
			id:busy
			anchors.centerIn : parent
			running:true
			width:CreateAppSipAccountStyle.busy.size
			height:CreateAppSipAccountStyle.busy.size
		}

		Icon{
			visible: webview.status != 0
			icon: (webview.status>0?"chat_read":"chat_error")
			iconSize:busy.width
			anchors.fill:busy
			onVisibleChanged:if(visible)webview.visible=false
			MouseArea{
				anchors.fill:parent
				onClicked:assistant.popView()
			}
		}
	}
}
