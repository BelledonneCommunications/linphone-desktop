import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { CallWindow } from "callWindow.js";

var INSTANCE_POOL = ["redial1", "redial2", "redial3", "redial4", "redial5", "redial6"];
var instanceIndex = 0;
var context = null;

// The whole contact detail must fit: an entry below the fold is clipped, and Squish refuses
// to click clipped items.
function maximizeMainWindow(){
    var window = App.window(10000);
    if (!window) return;
    try { window.showMaximized(); } catch (e) {
        try { window.visibility = 4; } catch (ignored) {}
    }
    snooze(1);
    try { test.log("Main window is " + window.width + "x" + window.height); } catch (ignored) {}
}

export var RedialFixture = {
    contactCreated: false,
    startScenario: function(){
        if (instanceIndex >= INSTANCE_POOL.length)
            test.fatal("Not enough pre-seeded profiles: add more to INSTANCE_POOL and to run-ci.sh");
        var instance = INSTANCE_POOL[instanceIndex];
        instanceIndex = instanceIndex + 1;
        RedialFixture.contactCreated = false;
        test.log("Scenario runs on a fresh profile: " + instance);
        context = App.launchInstance(instance);
        var loaded = App.withInstance(context, function(){ return MainPage.waitLoaded(); });
        if (!loaded) test.fatal("App did not reach the main page on profile " + instance);
        maximizeMainWindow();
    },
    endScenario: function(){
        CallWindow.endCallIfAny();
        try { if (context) context.kill(); } catch (e) {
            try { context.detach(); } catch (ignored) {}
        }
        snooze(1);
        context = null;
    }
};
