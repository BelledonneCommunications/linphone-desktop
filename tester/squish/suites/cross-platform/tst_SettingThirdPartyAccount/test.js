import { App } from "app.js";
import { WelcomePage } from "welcomePage.js";
import { Settings } from "settingsPage.js";

var CTX = "LoginPage";
var FEATURE = "assistant_login_third_party_sip_account_title";
var ANCHOR = "assistant_account_register";

function main(){
    var shown = App.launchInstance("set-tp-show");
    var hidden = App.launchInstance("set-tp-hide");

    App.withInstance(shown, function(){
        WelcomePage.skipIfPresent();
        test.verify(Settings.shows(CTX, ANCHOR), "login page reached");
        test.verify(Settings.shows(CTX, FEATURE), "third-party SIP account shown when assistant_hide_third_party_account=0");
    });
    App.withInstance(hidden, function(){
        WelcomePage.skipIfPresent();
        test.verify(Settings.shows(CTX, ANCHOR), "login page reached");
        test.verify(Settings.hides(CTX, FEATURE), "third-party SIP account hidden when assistant_hide_third_party_account=1");
    });
}
