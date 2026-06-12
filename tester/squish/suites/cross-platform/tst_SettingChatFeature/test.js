import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";

var CTX = "MainLayout";
var FEATURE = "open_conversations_page_accessible_name";

function main(){
    var shown = App.launchInstance("set-chat-show");
    var hidden = App.launchInstance("set-chat-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (chat shown)");
        test.verify(Settings.shows(CTX, FEATURE), "Conversations tab shown when disable_chat_feature=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (chat hidden)");
        test.verify(Settings.hides(CTX, FEATURE), "Conversations tab hidden when disable_chat_feature=1");
    });
}
