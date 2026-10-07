import * as L from "squishlib.js";
import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { WelcomePage } from "welcomePage.js";
import { CallPage } from "callPage.js";
import { CallWindow } from "callWindow.js";
import { provisionedAccount } from "serverAccount.js";

var SIGNED_IN_PROFILE = "a11y";
var PEER_PROFILE = "a11ypeer";
var GUEST_PROFILE = "a11yguest";
var CALLER_PROFILE = "a";
var CALLEE_PROFILE = "b";

var contexts = [];

function launch(profile){
    var context = App.launchInstance(profile);
    contexts.push(context);
    setApplicationContext(context);
    return context;
}

function maximize(){
    var window = App.window(10000);
    if (!window) return;
    try { window.showMaximized(); } catch (e) {
        try { window.visibility = 4; } catch (ignored) {}
    }
    snooze(1);
}

export var A11yFixture = {
    launchSignedIn: function(){
        var context = launch(SIGNED_IN_PROFILE);
        if (!MainPage.waitLoaded()) test.fatal("App did not reach the main page on profile " + SIGNED_IN_PROFILE);
        maximize();
        return context;
    },
    relaunchSignedIn: function(context){
        try { context.kill(); } catch (e) {
            try { context.detach(); } catch (ignored) {}
        }
        var index = contexts.indexOf(context);
        if (index >= 0) contexts.splice(index, 1);
        snooze(2);
        return A11yFixture.launchSignedIn();
    },
    launchSignedInWithPeer: function(){
        var peer = launch(PEER_PROFILE);
        if (!MainPage.waitLoaded()) test.fatal("App did not reach the main page on profile " + PEER_PROFILE);
        var context = A11yFixture.launchSignedIn();
        return { context: context, peer: peer };
    },
    launchCallPair: function(){
        var peer = launch(CALLEE_PROFILE);
        if (!MainPage.waitLoaded()) test.fatal("App did not reach the main page on profile " + CALLEE_PROFILE);
        var context = launch(CALLER_PROFILE);
        if (!MainPage.waitLoaded()) test.fatal("App did not reach the main page on profile " + CALLER_PROFILE);
        maximize();
        return { context: context, peer: peer };
    },
    callStateOf: function(window){
        try { return String(window.callState); } catch (e) { return "unreadable"; }
    },
    startConnectedCall: function(){
        var launched = A11yFixture.launchCallPair();
        CallPage.open();
        CallPage.callBySip(provisionedAccount("B"));
        App.withInstance(launched.peer, function(){ CallPage.accept(); });
        setApplicationContext(launched.context);
        var window = CallWindow.waitStarted(20000);
        if (!window) test.fatal("Call window not found");
        var lastState = null;
        var deadline = Date.now() + 30000;
        do {
            if (!L.waitForWindowNamed("callsWindow", 500))
                test.fatal("The call ended before it was connected, last call state: " + lastState);
            var state = A11yFixture.callStateOf(window);
            if (state !== lastState) {
                test.log("Call state: " + state);
                lastState = state;
            }
            if (L.namedIn(window, "callMoreOptionsButton")) return window;
            snooze(0.5);
        } while (Date.now() < deadline);
        test.fatal("The call never reached a connected state, last call state: " + lastState);
        return null;
    },
    activate: function(window){
        var deadline = Date.now() + 10000;
        do {
            try { if (window.active) return true; } catch (e) { return false; }
            try { window.raise(); window.requestActivate(); } catch (e) {}
            snooze(0.5);
        } while (Date.now() < deadline);
        return false;
    },
    launchGuest: function(){
        var context = launch(GUEST_PROFILE);
        if (!App.window(30000)) test.fatal("App window did not show on profile " + GUEST_PROFILE);
        WelcomePage.skipIfPresent();
        maximize();
        return context;
    },
    endScenario: function(){
        for (var i = contexts.length - 1; i >= 0; i--) {
            try { contexts[i].kill(); } catch (e) {
                try { contexts[i].detach(); } catch (ignored) {}
            }
        }
        contexts = [];
        snooze(1);
    }
};
