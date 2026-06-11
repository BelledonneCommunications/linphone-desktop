import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { CallPage } from "callPage.js";
import { provisionedAccount } from "serverAccount.js";

function main(){
    var accountA = provisionedAccount("A");
    var accountB = provisionedAccount("B");

    var ctxA = App.launchInstance("a");
    var ctxB = App.launchInstance("b");
    App.withInstance(ctxA, function(){ test.verify(MainPage.waitLoaded(), "A ready"); });
    App.withInstance(ctxB, function(){ test.verify(MainPage.waitLoaded(), "B ready"); });

    App.withInstance(ctxA, function(){
        CallPage.open();
        CallPage.callBySip(accountB);
    });
    App.withInstance(ctxB, function(){
        CallPage.accept();
    });

    var aConnected = App.withInstance(ctxA, function(){ return CallPage.waitConnected(25000); });
    var bConnected = App.withInstance(ctxB, function(){ return CallPage.waitConnected(25000); });
    test.verify(aConnected, "A side connected: call duration running");
    test.verify(bConnected, "B side connected: call duration running");
}
