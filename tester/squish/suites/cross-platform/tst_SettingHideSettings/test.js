import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var FEATURE = "settings_title";

function main(){
    var shown = App.launchInstance("set-menu-show");
    var hidden = App.launchInstance("set-menu-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (settings shown)");
        test.verify(Settings.openOptionsMenu(), "options menu opened (shown)");
        test.verify(Settings.shows(FEATURE), "Settings entry shown when hide_settings=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (settings hidden)");
        test.verify(Settings.openOptionsMenu(), "options menu opened (hidden)");
        test.verify(Settings.hides(FEATURE), "Settings entry hidden when hide_settings=1");
    });
}
