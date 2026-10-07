import * as L from "squishlib.js";
import { tr } from "translate.js";
import { App } from "app.js";
import { A11yFixture } from "a11yFixture.js";

function tx(o){ try { return o.text ? String(o.text) : ""; } catch (e) { return ""; } }

var MENUS = {
    "main options menu": {
        reach: function(){
            A11yFixture.launchSignedIn();
            var window = App.window(10000);
            if (!window) test.fatal("Main window not found");
            return { window: window, find: function(){ return L.namedIn(window, "mainOptionsButton"); } };
        },
        firstOption: function(){ return tr("drawer_menu_manage_account"); }
    },
    "in-call options menu": {
        reach: function(){
            var window = A11yFixture.startConnectedCall();
            return {
                window: window,
                find: function(){
                    if (!L.waitForWindowNamed("callsWindow", 1000))
                        test.fatal("The call ended before the options menu could be reached, last call state: " + A11yFixture.callStateOf(window));
                    return L.namedIn(window, "callMoreOptionsButton");
                }
            };
        },
        firstOption: function(){ return tr("call_action_full_screen"); }
    }
};

function menuNamed(name){
    var menu = MENUS[name];
    if (!menu) test.fatal("Unknown menu in the spec: " + name);
    return menu;
}

function focusedItem(window){
    try { return window.activeFocusItem; } catch (e) { return null; }
}

function focusButton(context, name){
    var menu = menuNamed(name);
    var reached = menu.reach();
    if (!A11yFixture.activate(reached.window)) test.fatal("The window holding the " + name + " could not be activated");
    var button = null;
    var deadline = Date.now() + 20000;
    do {
        button = reached.find();
        if (button) {
            try { button.forceActiveFocus(); } catch (e) {}
            snooze(0.5);
            try { if (button.activeFocus) break; } catch (e) {}
        } else {
            snooze(0.5);
        }
    } while (Date.now() < deadline);
    if (!button) test.fatal("Button opening the " + name + " not found");
    var focused = false;
    try { focused = !!button.activeFocus; } catch (e) {}
    if (!focused) test.fatal("Could not move the keyboard focus to the button opening the " + name);
    context.userData = { menu: menu, window: reached.window, button: button };
}

function openWithKeyboard(context){
    type(context.userData.window, "<Return>");
    var deadline = Date.now() + 5000;
    do {
        if (context.userData.button.popup.visible) break;
        snooze(0.3);
    } while (Date.now() < deadline);
    snooze(0.5);
}

Given("the keyboard focus is on the button opening the |any|", function(context, name){
    focusButton(context, name);
});

Given("the user has opened the |any| with the keyboard", function(context, name){
    focusButton(context, name);
    openWithKeyboard(context);
    if (!context.userData.button.popup.visible) test.fatal("The " + name + " did not open");
});

When("the user opens the menu with the keyboard", function(context){
    openWithKeyboard(context);
});

When("the user closes the menu with the keyboard", function(context){
    type(context.userData.window, "<Escape>");
    snooze(1);
});

Then("the focus is on the first option of the |any|", function(context, name){
    test.verify(context.userData.button.popup.visible, "The " + name + " is open");
    var focused = focusedItem(context.userData.window);
    if (!focused) test.fatal("Nothing has the keyboard focus");
    test.compare(tx(focused), context.userData.menu.firstOption(), "The focus is on the first option of the " + name);
    test.verify(!!focused.keyboardFocus, "The focused option shows the keyboard focus indicator");
});

Then("the |any| is closed", function(context, name){
    test.verify(!context.userData.button.popup.visible, "The " + name + " is closed");
});

Then("the focus is back on the button opening the |any|", function(context, name){
    test.verify(!!context.userData.button.activeFocus, "The focus is back on the button opening the " + name);
});
