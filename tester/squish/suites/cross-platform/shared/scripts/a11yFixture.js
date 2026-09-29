import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { WelcomePage } from "welcomePage.js";

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
