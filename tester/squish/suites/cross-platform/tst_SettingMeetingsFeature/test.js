import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var FEATURE = "bottom_navigation_meetings_label";

function main(){
    var shown = App.launchInstance("set-meet-show");
    var hidden = App.launchInstance("set-meet-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (meetings shown)");
        test.verify(Settings.shows(FEATURE), "Meetings tab shown when disable_meetings_feature=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (meetings hidden)");
        test.verify(Settings.hides(FEATURE), "Meetings tab hidden when disable_meetings_feature=1");
    });
}
