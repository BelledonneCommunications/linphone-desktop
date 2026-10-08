import * as L from "squishlib.js";
import { App } from "app.js";
import { A11yFixture } from "a11yFixture.js";
import { ContactsPage } from "contactsPage.js";
import { CallPage } from "callPage.js";
import { CallWindow } from "callWindow.js";
import { Settings } from "settingsPage.js";
import { provisionedAccount } from "serverAccount.js";

var CONTACT_NAME = "Keyboard Access Robot";

var KEYS = {
    "Down": "<Down>",
    "Up": "<Up>",
    "Space": "<Space>",
    "Right": "<Right>",
    "Left": "<Left>",
    "Tab": "<Tab>",
    "Shift+Tab": "<Shift+Tab>",
    "Escape": "<Escape>",
    "Shift+F10": "<Shift+F10>"
};

var PICKERS = {
    "date picker": "meetingStartDate",
    "start time picker": "meetingStartHour"
};

function nameOf(o){ try { return o.objectName ? String(o.objectName) : ""; } catch (e) { return ""; } }

function exists(o){
    return o !== null && o !== undefined && !isNull(o);
}

function mainWindow(){
    var window = App.window(10000);
    if (!window) test.fatal("Main window not found");
    return window;
}

function named(name, timeoutMs){
    var element = L.waitForNamed(name, timeoutMs || 20000);
    if (!element) test.fatal("No visible element with objectName " + name);
    return element;
}

function focusedName(window){
    var item = null;
    try { item = window.activeFocusItem; } catch (e) { return ""; }
    return exists(item) ? nameOf(item) : "";
}

function focus(context, element){
    var window = context.userData.window;
    A11yFixture.activate(window);
    var deadline = Date.now() + 10000;
    do {
        try { element.forceActiveFocus(); } catch (e) {}
        snooze(0.3);
        try { if (element.activeFocus) return; } catch (e) {}
    } while (Date.now() < deadline);
    test.fatal("Could not move the keyboard focus to " + nameOf(element));
}

function waitTrue(check, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 5000);
    do {
        try { if (check()) return true; } catch (e) {}
        snooze(0.3);
    } while (Date.now() < deadline);
    try { return !!check(); } catch (e) { return false; }
}

function popupVisible(owner){
    return waitTrue(function(){ return owner.popup.visible; });
}

function ensureContact(){
    ContactsPage.open();
    if (!L.waitForText(CONTACT_NAME, 5000))
        ContactsPage.create(CONTACT_NAME, "sip:keyboard-access-robot@" + provisionedAccount("A").domain);
    ContactsPage.open();
}

Given("the user is signed in", function(context){
    A11yFixture.launchSignedIn();
    context.userData = { window: mainWindow() };
});

Given("the user has moved the keyboard focus to the main tab |integer|", function(context, position){
    focus(context, named("mainTab" + (position - 1)));
});

Then("the keyboard focus is on the main tab |integer|", function(context, position){
    test.compare(focusedName(context.userData.window), "mainTab" + (position - 1), "The keyboard focus is on the main tab " + position);
});

Given("the main tab |integer| has been selected", function(context, position){
    var tab = named("mainTab" + (position - 1));
    if (!tab.checked) mouseClick(tab);
    if (!waitTrue(function(){ return tab.checked; })) test.fatal("The main tab " + position + " could not be selected");
});

Then("the keyboard focus has left the main tabs", function(context){
    test.verify(waitTrue(function(){
        var name = focusedName(context.userData.window);
        return name.indexOf("mainTab") !== 0;
    }), "The keyboard focus has left the main tabs");
});

Then("the main tab |integer| is selected", function(context, position){
    var tab = named("mainTab" + (position - 1));
    test.verify(waitTrue(function(){ return tab.checked; }), "The main tab " + position + " is selected");
});

When("the user presses |any|", function(context, pressed){
    var key = KEYS[pressed];
    if (!key) test.fatal("Unknown key in the spec: " + pressed);
    type(context.userData.window, key);
    snooze(0.8);
});

Given("the user has a contact", function(context){
    A11yFixture.launchSignedIn();
    context.userData = { window: mainWindow() };
    ensureContact();
});

Given("the keyboard focus is on the contact in the contact list", function(context){
    var row = L.waitFor(function(o){
        return nameOf(o) === "contactRow" && o.visible && L.containsText(o.parent, CONTACT_NAME) !== null;
    }, 20000);
    if (!row) row = named("contactRow");
    context.userData.contactRow = row;
    focus(context, row);
});

function isInside(item, name){
    for (var node = item; exists(node); node = node.parent) {
        if (nameOf(node) === name) return true;
    }
    return false;
}

Then("the keyboard focus is in the contact details", function(context){
    var window = context.userData.window;
    test.verify(waitTrue(function(){ return isInside(window.activeFocusItem, "contactDetail"); }), "The keyboard focus is in the contact details");
});

Then("the keyboard focus is back on the contact", function(context){
    var row = context.userData.contactRow;
    test.verify(waitTrue(function(){ return row.activeFocus; }), "The keyboard focus is back on the contact");
});

Then("the contact menu is open", function(context){
    var menu = named("contactMenuButton");
    context.userData.contactMenu = menu;
    test.verify(popupVisible(menu), "The contact menu is open");
});

Then("the keyboard focus is in the contact menu", function(context){
    var menu = context.userData.contactMenu;
    test.verify(waitTrue(function(){ return menu.popup.activeFocus; }), "The keyboard focus is in the contact menu");
});

Given("the user has a call in the call history", function(context){
    A11yFixture.startConnectedCall();
    CallWindow.endCallIfAny();
    context.userData = { window: mainWindow() };
    CallPage.open();
    named("callHistoryRow", 30000);
});

Given("the keyboard focus is on the call history entry", function(context){
    focus(context, named("callHistoryRow"));
});

Then("the call options menu is open", function(context){
    var options = named("callHistoryOptionsButton");
    test.verify(popupVisible(options), "The call options menu is open");
});

When("an assistive technology activates the main options button", function(context){
    var button = named("mainOptionsButton");
    context.userData.optionsButton = button;
    button.accessiblePressAction();
    snooze(0.8);
});

Then("the main options menu is open", function(context){
    test.verify(popupVisible(context.userData.optionsButton), "The main options menu is open");
});

Given("the user is creating a meeting", function(context){
    A11yFixture.launchSignedIn();
    context.userData = { window: mainWindow() };
    Settings.openMeetingForm();
    named("meetingStartDate", 20000);
});

Given("the user has opened the |any| with the keyboard", function(context, picker){
    var name = PICKERS[picker];
    if (!name) test.fatal("Unknown picker in the spec: " + picker);
    var combo = named(name);
    context.userData.picker = combo;
    focus(context, combo);
    type(context.userData.window, "<Space>");
    if (!popupVisible(combo)) test.fatal("The " + picker + " did not open with Space");
});

Then("the |any| is closed", function(context, picker){
    var combo = context.userData.picker;
    test.verify(waitTrue(function(){ return !combo.popup.visible; }), "The " + picker + " is closed");
});

Given("the user is in the call settings", function(context){
    A11yFixture.launchSignedIn();
    context.userData = { window: mainWindow() };
    if (!Settings.openSettingsPage()) test.fatal("Settings page not reached");
    named("outputAudioDeviceComboBox", 20000);
});

Given("the keyboard focus is on the audio output device list", function(context){
    var combo = named("outputAudioDeviceComboBox");
    context.userData.combo = combo;
    focus(context, combo);
});

Then("the audio output device list is open", function(context){
    test.verify(popupVisible(context.userData.combo), "The audio output device list is open");
});
