import { App } from "app.js";
import { WelcomePage } from "welcomePage.js";
import { Settings } from "settingsPage.js";

var CTX = "LoginPage";
var FEATURE = "assistant_account_register";
var ANCHOR = "assistant_login_third_party_sip_account_title";

function main(){
    var shown = App.launchInstance("set-ca-show");
    var hidden = App.launchInstance("set-ca-hide");

    App.withInstance(shown, function(){
        WelcomePage.skipIfPresent();
        test.verify(Settings.shows(CTX, ANCHOR), "login page reached");
        test.verify(Settings.shows(CTX, FEATURE), "create-account shown when assistant_hide_create_account=0");
    });
    App.withInstance(hidden, function(){
        WelcomePage.skipIfPresent();
        test.verify(Settings.shows(CTX, ANCHOR), "login page reached");
        test.verify(Settings.hides(CTX, FEATURE), "create-account hidden when assistant_hide_create_account=1");
    });
}
