import { App } from "app.js";
import { A11yFixture } from "a11yFixture.js";

function exists(o){
    return o !== null && o !== undefined && !isNull(o);
}

function waitTrue(check, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 10000);
    do {
        try { if (check()) return true; } catch (e) {}
        snooze(0.3);
    } while (Date.now() < deadline);
    try { return !!check(); } catch (e) { return false; }
}

function windowOf(context, which){
    return which === "call" ? context.userData.callWindow : context.userData.mainWindow;
}

Given("the user is in a call", function(context){
    var callWindow = A11yFixture.startConnectedCall();
    var mainWindow = App.window(10000);
    if (!exists(mainWindow)) test.fatal("Main window not found");
    context.userData = { callWindow: callWindow, mainWindow: mainWindow };
});

Given("the main window is the active window", function(context){
    if (!A11yFixture.activate(context.userData.mainWindow)) test.fatal("The main window could not be activated");
});

When("the user presses F6", function(context){
    type(context.userData.mainWindow.active ? context.userData.mainWindow : context.userData.callWindow, "<F6>");
});

When("the user presses Shift+F6", function(context){
    type(context.userData.callWindow.active ? context.userData.callWindow : context.userData.mainWindow, "<Shift+F6>");
});

Then("the |word| window is the active window", function(context, which){
    var window = windowOf(context, which);
    test.verify(waitTrue(function(){ return window.active; }), "The " + which + " window is the active window");
});

Then("the |word| window has the keyboard focus inside it", function(context, which){
    var window = windowOf(context, which);
    test.verify(waitTrue(function(){
        var item = window.activeFocusItem;
        return exists(item) && item.activeFocusOnTab === true;
    }), "The " + which + " window has the keyboard focus inside it");
});

Then("the call window title names the other participant", function(context){
    var window = context.userData.callWindow;
    var remoteName = "";
    try { remoteName = String(window.call.core.remoteName); } catch (e) {}
    if (!remoteName) test.fatal("The remote name of the call could not be read");
    var title = String(window.title);
    test.log("Call window title: " + title);
    test.verify(title.indexOf(remoteName) >= 0, "The call window title names the other participant");
});
