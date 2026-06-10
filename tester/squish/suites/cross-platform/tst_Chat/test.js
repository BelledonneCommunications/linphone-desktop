import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { ChatPage } from "chatPage.js";
import { provisionedAccount } from "serverAccount.js";

function main(){
    var accountA = provisionedAccount("A");
    var accountB = provisionedAccount("B");
    var message = "Hello from A " + Date.now();

    var ctxA = App.launchInstance("a");
    var ctxB = App.launchInstance("b");
    App.withInstance(ctxA, function(){ test.verify(MainPage.waitLoaded(), "A ready"); });
    App.withInstance(ctxB, function(){ test.verify(MainPage.waitLoaded(), "B ready"); });

    App.withInstance(ctxA, function(){
        ChatPage.open();
        ChatPage.startChatWith(accountB);
        ChatPage.sendMessage(message);
    });

    App.withInstance(ctxB, function(){
        ChatPage.open();
        ChatPage.openConversationWith(accountA);
        test.verify(ChatPage.waitForMessage(message, 30000), "B received message from A: "+message);
    });
}
