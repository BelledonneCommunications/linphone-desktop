import * as L from "squishlib.js";
import { tr } from "translate.js";
import { A11yFixture } from "a11yFixture.js";

var KEY_PRESSES = 25;

function tx(o){ try { return o.text ? String(o.text) : ""; } catch (e) { return ""; } }
function nameOf(o){ try { return o.objectName ? String(o.objectName) : ""; } catch (e) { return ""; } }

function exists(o){
    return o !== null && o !== undefined && !isNull(o);
}

function focusedItem(window){
    var item = null;
    try { item = window.activeFocusItem; } catch (e) { return null; }
    return exists(item) ? item : null;
}

function focusIsInPanel(window, container){
    var current = focusedItem(window);
    for (var i = 0; i < 60 && current; i++) {
        if (nameOf(current) === container) return true;
        var parent = null;
        try { parent = current.parent; } catch (e) { return false; }
        current = exists(parent) ? parent : null;
    }
    return false;
}

function focusControl(window, control, description){
    if (!A11yFixture.activate(window)) test.fatal("The call window could not be activated");
    var deadline = Date.now() + 10000;
    do {
        try { control.forceActiveFocus(); } catch (e) {}
        snooze(0.5);
        try { if (control.activeFocus) return; } catch (e) {}
    } while (Date.now() < deadline);
    test.fatal("Could not move the keyboard focus to the " + description);
}

function waitForNamedIn(window, name, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 15000);
    do {
        var found = L.namedIn(window, name);
        if (found) return found;
        snooze(0.5);
    } while (Date.now() < deadline);
    test.fatal("No visible element with objectName " + name + " in the call window");
    return null;
}

function openDialer(window){
    var button = waitForNamedIn(window, "dtmfPadButton");
    focusControl(window, button, "dialer button");
    type(window, "<Return>");
    return button;
}

function openCallList(window){
    var button = waitForNamedIn(window, "callListButton");
    focusControl(window, button, "call list button");
    type(window, "<Return>");
    return button;
}

var PANELS = {
    "dialer": { content: "dtmfPadPanel", container: "dtmfPadPanel", title: "call_action_show_dialer", open: openDialer },
    "call list": { content: "callListPanel", container: "callSidePanel", title: "call_action_go_to_calls_list", open: openCallList }
};

function panelNamed(name){
    var panel = PANELS[name];
    if (!panel) test.fatal("Unknown panel in the spec: " + name);
    return panel;
}

function panelShows(window, panel){
    if (L.namedIn(window, panel.content) !== null) return true;
    var side = L.namedIn(window, panel.container);
    return side !== null && L.textIn(side, tr(panel.title)) !== null;
}

function describePanelState(window, panel, opener){
    var side = L.namedIn(window, panel.container);
    var checked = "n/a";
    try { checked = String(opener.checked); } catch (e) {}
    var focused = focusedItem(window);
    return "panel visible=" + (side !== null) + ", opener checked=" + checked
        + ", focus on name=" + nameOf(focused) + " text=" + tx(focused);
}

function pressRepeatedly(context, name, key){
    var container = panelNamed(name).container;
    context.userData.left = false;
    for (var i = 0; i < KEY_PRESSES; i++) {
        type(context.userData.window, key);
        snooze(0.3);
        if (!focusIsInPanel(context.userData.window, container)) {
            context.userData.left = true;
            test.log("The keyboard focus left the panel after " + (i + 1) + " presses of " + key);
            return;
        }
    }
}

Given("the user is in a call", function(context){
    context.userData = { window: A11yFixture.startConnectedCall() };
});

Given("the user has opened the |any| with the keyboard", function(context, name){
    var panel = panelNamed(name);
    context.userData.opener = panel.open(context.userData.window);
    var deadline = Date.now() + 10000;
    do {
        if (panelShows(context.userData.window, panel)) break;
        snooze(0.5);
    } while (Date.now() < deadline);
    var shown = panelShows(context.userData.window, panel);
    if (!shown) test.log("Panel state: " + describePanelState(context.userData.window, panel, context.userData.opener));
    test.verify(shown, "The " + name + " is open");
    snooze(1);
});

Then("the keyboard focus is on the digit 1 of the dialer", function(context){
    test.compare(nameOf(focusedItem(context.userData.window)), "numericPadKey1", "The keyboard focus is on the digit 1 of the dialer");
});

Then("the keyboard focus is in the |any|", function(context, name){
    test.verify(focusIsInPanel(context.userData.window, panelNamed(name).container), "The keyboard focus is in the " + name);
});

When("the user moves the keyboard focus forward through the |any| several times", function(context, name){
    pressRepeatedly(context, name, "<Tab>");
});

When("the user moves the keyboard focus backward through the |any| several times", function(context, name){
    pressRepeatedly(context, name, "<Shift+Tab>");
});

Then("the keyboard focus never left the |any|", function(context, name){
    test.verify(!context.userData.left, "The keyboard focus never left the " + name);
});

When("the user closes the panel with the keyboard", function(context){
    type(context.userData.window, "<Escape>");
    snooze(1);
});

Then("the |any| is closed", function(context, name){
    var container = panelNamed(name).container;
    var deadline = Date.now() + 5000;
    do {
        if (!L.namedIn(context.userData.window, container)) break;
        snooze(0.5);
    } while (Date.now() < deadline);
    test.verify(!L.namedIn(context.userData.window, container), "The " + name + " is closed");
});

Then("the keyboard focus is back on the control that opened the |any|", function(context, name){
    var opener = context.userData.opener;
    var deadline = Date.now() + 5000;
    do {
        try { if (opener.activeFocus) break; } catch (e) {}
        snooze(0.5);
    } while (Date.now() < deadline);
    var focused = false;
    try { focused = !!opener.activeFocus; } catch (e) {}
    test.verify(focused, "The keyboard focus is back on the control that opened the " + name);
});
