import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var CTX = "MainLayout";
var FEATURE = "drawer_menu_manage_account";

function main(){
    var shown = App.launchInstance("set-menu-show");
    var hidden = App.launchInstance("set-menu-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (shown)");
        test.verify(Settings.openOptionsMenu(), "options menu opened (shown)");
        test.verify(Settings.shows(CTX, FEATURE), "My account entry shown when hide_account_settings=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (hidden)");
        test.verify(Settings.openOptionsMenu(), "options menu opened (hidden)");
        test.verify(Settings.hides(CTX, FEATURE), "My account entry hidden when hide_account_settings=1");
    });
}
