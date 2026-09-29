import * as L from "squishlib.js";
import { App } from "app.js";
import { A11yFixture } from "a11yFixture.js";
import { ChatPage } from "chatPage.js";
import { provisionedAccount } from "serverAccount.js";

var MAX_TAB_PRESSES = 40;

var peer = null;
var signedIn = null;

var KEYS = {
    "Enter": "<Return>",
    "Space": "<Space>"
};

function nameOf(o){ try { return o.objectName ? String(o.objectName) : ""; } catch (e) { return ""; } }

function chatList(){
    var list = L.waitForNamed("chatListView", 20000);
    if (!list) test.fatal("Conversation list not found");
    return list;
}

function conversationIsOpen(){
    var chat = null;
    try { chat = chatList().currentChatGui; } catch (e) { return false; }
    return chat !== null && chat !== undefined && !isNull(chat);
}

function focusedItem(){
    var window = App.window(10000);
    try { return window ? window.activeFocusItem : null; } catch (e) { return null; }
}

function focusIsOnConversation(){
    var focused = focusedItem();
    return !!focused && nameOf(focused) === "chatListRow";
}

function tabToConversation(){
    var window = App.window(10000);
    for (var i = 0; i < MAX_TAB_PRESSES; i++) {
        if (focusIsOnConversation()) return;
        type(window, "<Tab>");
        snooze(0.3);
    }
    if (!focusIsOnConversation()) test.fatal("The keyboard focus never reached the conversation with Tab");
}

Given("the user has a conversation with another user", function(context){
    var launched = A11yFixture.launchSignedInWithPeer();
    peer = launched.peer;
    signedIn = launched.context;
    ChatPage.open();
    if (!L.waitForNamed("chatListRow", 8000)) {
        ChatPage.startChatWith(provisionedAccount("B"));
        ChatPage.sendMessage("Keyboard navigation " + Date.now());
        signedIn = A11yFixture.relaunchSignedIn(signedIn);
        ChatPage.open();
    }
    if (!L.waitForNamed("chatListRow", 20000)) test.fatal("No conversation listed");
});

Step("no conversation is open", function(context){
    snooze(1);
    test.verify(!conversationIsOpen(), "No conversation is open");
});

When("the user moves the keyboard focus to the conversation", function(context){
    tabToConversation();
});

Given("the keyboard focus is on the conversation", function(context){
    tabToConversation();
});

When("the other user sends a message in the conversation", function(context){
    var message = "Incoming while focused " + Date.now();
    App.withInstance(peer, function(){
        ChatPage.open();
        ChatPage.openConversationWith(provisionedAccount("A"));
        ChatPage.sendMessage(message);
    });
    setApplicationContext(signedIn);
    var window = App.window(10000);
    try { window.requestActivate(); } catch (e) {}
    if (!ChatPage.waitForMessage(message, 30000)) test.fatal("The message from the other user never showed up in the list");
    snooze(2);
});

Then("the keyboard focus stays on the conversation", function(context){
    test.verify(focusIsOnConversation(), "The keyboard focus is on the conversation");
});

When("the user presses |any|", function(context, pressed){
    var key = KEYS[pressed];
    if (!key) test.fatal("Unknown key in the spec: " + pressed);
    type(App.window(10000), key);
    snooze(1);
});

Then("the conversation is open", function(context){
    var deadline = Date.now() + 10000;
    do {
        if (conversationIsOpen()) break;
        snooze(0.5);
    } while (Date.now() < deadline);
    test.verify(conversationIsOpen(), "The conversation is open");
});
