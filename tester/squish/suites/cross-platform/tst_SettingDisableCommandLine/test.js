import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var FEATURE = "settings_calls_command_line_title";
var ANCHOR = "settings_call_devices_title";

function openCallSettings(){
    Settings.openSettingsPage();
}

function main(){
    var shown = App.launchInstance("set-cli-show");
    var hidden = App.launchInstance("set-cli-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (command line shown)");
        openCallSettings();
        test.verify(Settings.shows(ANCHOR), "call settings opened (shown)");
        test.verify(Settings.shows(FEATURE), "Command line shown when disable_command_line=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (command line hidden)");
        openCallSettings();
        test.verify(Settings.shows(ANCHOR), "call settings opened (hidden)");
        test.verify(Settings.hides(FEATURE), "Command line hidden when disable_command_line=1");
    });
}
