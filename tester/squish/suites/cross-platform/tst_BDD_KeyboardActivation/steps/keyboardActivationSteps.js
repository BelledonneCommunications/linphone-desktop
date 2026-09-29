import * as L from "squishlib.js";
import { tr } from "translate.js";
import { A11yFixture } from "a11yFixture.js";
import { Settings } from "settingsPage.js";
import { ContactsPage } from "contactsPage.js";
import { ChatPage } from "chatPage.js";
import { provisionedAccount } from "serverAccount.js";

var CONTACT_NAME = "Keyboard Robot";

var KEYS = {
    "Enter": "<Return>",
    "Space": "<Space>",
    "Ctrl+Enter": "<Ctrl+Return>",
    "Shift+Enter": "<Shift+Return>"
};

function cnn(o){ try { return className(o); } catch (e) { return ""; } }
function tx(o){ try { return o.text ? String(o.text) : ""; } catch (e) { return ""; } }

function firstEnabledNamed(name, timeoutMs){
    if (!L.waitForNamed(name, timeoutMs || 20000)) test.fatal("No visible element with objectName: " + name);
    var deadline = Date.now() + 10000;
    do {
        var found = L.allNamed(name);
        for (var i = 0; i < found.length; i++) if (found[i].enabled) return found[i];
        snooze(0.5);
    } while (Date.now() < deadline);
    test.fatal("No enabled element with objectName: " + name);
    return null;
}

function childMatching(element, pattern){
    var children = [];
    try { children = object.children(element); } catch (e) { return null; }
    for (var i = 0; i < children.length; i++) if (pattern.test(cnn(children[i]))) return children[i];
    return null;
}

function disclosureContent(button){
    var header = object.parent(button);
    var section = header ? object.parent(header) : null;
    var content = section ? childMatching(section, /RoundedPane/) : null;
    if (!content) test.fatal("Disclosure content not found next to its toggle");
    return content;
}

function passwordField(button){
    var field = object.parent(button);
    if (!field || !/TextField/.test(cnn(field))) test.fatal("Password field not found around its visibility toggle");
    return field;
}

function ensureContactDetail(){
    ContactsPage.open();
    if (!L.waitForText(CONTACT_NAME, 5000))
        ContactsPage.create(CONTACT_NAME, "sip:keyboard-robot@" + provisionedAccount("A").domain);
    ContactsPage.select(CONTACT_NAME);
}

function openEphemeralSettings(){
    ChatPage.open();
    ChatPage.startChatWith(provisionedAccount("B"));
    L.clickNamed("chatDetailsPanelButton", 30000);
    snooze(1);
    var enableLabel = tr("one_one_infos_enable_ephemerals");
    var enabledLabel = tr("one_one_infos_ephemerals");
    var entry = L.waitFor(function(o){
        var text = tx(o);
        return o.visible && /Text/.test(cnn(o)) && (text === enableLabel || text.indexOf(enabledLabel) === 0);
    }, 20000);
    if (!entry) test.fatal("Ephemeral messages entry not found in the conversation details");
    mouseClick(entry);
    snooze(1);
}

var COMPONENTS = {
    "switch": {
        reach: function(){
            A11yFixture.launchSignedIn();
            if (!Settings.openSettingsPage()) test.fatal("Settings page not reached");
            return firstEnabledNamed("settingSwitch");
        },
        state: function(element){ return { checked: !!element.checked }; }
    },
    "checkbox": {
        reach: function(){
            A11yFixture.launchGuest();
            L.click(tr("assistant_account_register"), 20000);
            snooze(1);
            return firstEnabledNamed("registerTermsCheckBox");
        },
        state: function(element){ return { checked: !!element.checked }; }
    },
    "toggle button": {
        reach: function(){
            A11yFixture.launchGuest();
            return firstEnabledNamed("passwordVisibilityButton");
        },
        state: function(element){
            return { checked: !!element.checked, echoMode: Number(passwordField(element).echoMode) };
        },
        consistent: function(state){ return state.checked ? state.echoMode === 0 : state.echoMode !== 0; }
    },
    "disclosure": {
        reach: function(){
            A11yFixture.launchSignedIn();
            ensureContactDetail();
            return firstEnabledNamed("contactDetailExpandButton");
        },
        state: function(element){
            return { expanded: !!element.checked, contentShown: !!disclosureContent(element).visible };
        },
        consistent: function(state){ return state.expanded === state.contentShown; }
    }
};

function componentNamed(name){
    var component = COMPONENTS[name];
    if (!component) test.fatal("Unknown component in the spec: " + name);
    return component;
}

function focus(element){
    element.forceActiveFocus();
    snooze(0.5);
    if (!element.activeFocus) test.fatal("Could not move the keyboard focus to the component");
}

function describe(state){ return JSON.stringify(state); }

function currentState(context){
    snooze(0.5);
    var component = context.userData.component;
    var state = component.state(context.userData.element);
    if (component.consistent)
        test.verify(component.consistent(state), "The component shows what its state says: " + describe(state));
    return state;
}

Given("the keyboard focus is on a |any|", function(context, name){
    var component = componentNamed(name);
    var element = component.reach();
    focus(element);
    context.userData = { name: name, component: component, element: element };
    context.userData.initialState = currentState(context);
});

Given("the keyboard focus is on an unselected radio button", function(context){
    A11yFixture.launchSignedInWithPeer();
    openEphemeralSettings();
    firstEnabledNamed("ephemeralLifetimeRadioButton");
    var radios = L.allNamed("ephemeralLifetimeRadioButton");
    var target = null;
    var previous = null;
    for (var i = 0; i < radios.length; i++) {
        if (radios[i].checked) previous = radios[i];
        else if (!target && radios[i].enabled) target = radios[i];
    }
    if (!target) test.fatal("No unselected radio button available");
    focus(target);
    context.userData = { element: target, previous: previous };
});

When("the user presses |any|", function(context, pressed){
    var key = KEYS[pressed.replace(/ again$/, "")];
    if (!key) test.fatal("Unknown key in the spec: " + pressed);
    type(context.userData.element, key);
    snooze(0.5);
});

Then("the |any| has changed state", function(context, name){
    var state = currentState(context);
    test.verify(describe(state) !== describe(context.userData.initialState),
        "The " + name + " changed state: " + describe(context.userData.initialState) + " -> " + describe(state));
});

Then("the |any| is back to its initial state", function(context, name){
    test.compare(describe(currentState(context)), describe(context.userData.initialState),
        "The " + name + " is back to its initial state");
});

Then("the |any| has not changed state", function(context, name){
    test.compare(describe(currentState(context)), describe(context.userData.initialState),
        "The " + name + " did not change state");
});

Then("the radio button is selected", function(context){
    snooze(0.5);
    test.verify(context.userData.element.checked, "The focused radio button is selected");
});

Then("the previously selected option is no longer selected", function(context){
    if (!context.userData.previous) {
        test.log("No option was selected beforehand");
        return;
    }
    test.verify(!context.userData.previous.checked, "The previously selected option is no longer selected");
});

Then("the radio button is still selected", function(context){
    snooze(0.5);
    test.verify(context.userData.element.checked, "The focused radio button is still selected");
});
