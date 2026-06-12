import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var FEATURE = "settings_call_forward";

function main(){
    var shown = App.launchInstance("set-cf-show");
    var hidden = App.launchInstance("set-cf-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (call forward shown)");
        test.verify(Settings.openSettingsPage(), "settings page opened (shown)");
        test.verify(Settings.shows(FEATURE), "Call forward shown when disable_call_forward=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (call forward hidden)");
        test.verify(Settings.openSettingsPage(), "settings page opened (hidden)");
        test.verify(Settings.hides(FEATURE), "Call forward hidden when disable_call_forward=1");
    });
}
