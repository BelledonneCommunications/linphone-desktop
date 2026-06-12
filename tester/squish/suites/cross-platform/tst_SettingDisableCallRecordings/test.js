import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var FEATURE = "recordings_title";

function main(){
    var shown = App.launchInstance("set-menu-show");
    var hidden = App.launchInstance("set-menu-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (shown)");
        test.verify(Settings.openOptionsMenu(), "options menu opened (shown)");
        test.verify(Settings.shows(FEATURE), "Records entry shown when disable_call_recordings=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (hidden)");
        test.verify(Settings.openOptionsMenu(), "options menu opened (hidden)");
        test.verify(Settings.hides(FEATURE), "Records entry hidden when disable_call_recordings=1");
    });
}
