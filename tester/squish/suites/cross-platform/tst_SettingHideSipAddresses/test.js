import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";
import { provisionedAccount } from "serverAccount.js";

function main(){
    var accountA = provisionedAccount("A");
    var accountB = provisionedAccount("B");

    var shown = App.launchInstance("set-sip-show");
    var hidden = App.launchInstance("set-sip-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (sip shown)");
        test.verify(Settings.openMenuWith(accountA.username), "account menu opened (shown)");
        test.verify(Settings.showsText(accountA.identity), "SIP address shown when hide_sip_addresses=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (sip hidden)");
        test.verify(Settings.openMenuWith(accountB.username), "account menu opened (hidden)");
        test.verify(Settings.hidesText(accountB.identity), "SIP address hidden when hide_sip_addresses=1");
    });
}
