import * as L from "squishlib.js";
import { tr } from "translate.js";

function cnn(o){try{return className(o);}catch(e){return "";}}
function tx(o){try{return o.text?String(o.text):"";}catch(e){return "";}}

function popupButtons(){
    return L.findAll(function(o){return o.visible&&/PopupButton_QMLTYPE/.test(cnn(o));});
}

function openMenuWith(text){
    var buttons = popupButtons();
    for (var i = 0; i < buttons.length; i++) {
        mouseClick(buttons[i]);
        snooze(1.5);
        if (L.waitForText(text, 2500)) return true;
        try { type(buttons[i], "<Escape>"); } catch (e) {}
        snooze(0.5);
    }
    return false;
}

function describe(element, index){
    var fields = ["className=" + cnn(element)];
    var names = ["objectName", "visible", "clip", "x", "y", "width", "height", "contentY", "contentHeight"];
    for (var i = 0; i < names.length; i++) {
        try {
            var value = element[names[i]];
            if (value !== undefined) fields.push(names[i] + "=" + String(value));
        } catch (e) {}
    }
    return index + ": " + fields.join(" ");
}

function describeAncestors(element){
    var lines = [describe(element, 0)];
    var current = element;
    for (var i = 1; i < 12; i++) {
        try { current = object.parent(current); } catch (e) { break; }
        if (!current) break;
        lines.push(describe(current, i));
    }
    return lines.join("\n");
}

function ancestorFlickable(element){
    var current = element;
    for (var i = 0; i < 15; i++) {
        try { current = object.parent(current); } catch (e) { return null; }
        if (!current) return null;
        if (/Flickable/.test(cnn(current))) return current;
    }
    return null;
}

// Entries below the fold are clipped by their scrolling parent, and mouseClick refuses them.
function clickScrolledIntoView(element){
    var flickable = ancestorFlickable(element);
    for (var attempt = 0; attempt < 15; attempt++) {
        try { mouseClick(element); return; } catch (e) {}
        if (!flickable) {
            try { element.forceActiveFocus(); } catch (ignored) {}
            snooze(0.5);
            continue;
        }
        try {
            var maximum = flickable.contentHeight - flickable.height;
            var next = flickable.contentY + 120;
            flickable.contentY = next > maximum ? maximum : next;
        } catch (ignored) {}
        snooze(0.4);
    }
    test.log("Clipped element diagnostics:\n" + describeAncestors(element));
    test.fatal("Element is still clipped after scrolling, cannot click it");
}

function entryShowing(text, timeoutMs){
    return L.waitFor(function(o){
        return o.visible && tx(o) === text && /Text_QMLTYPE/.test(cnn(o));
    }, timeoutMs || 15000);
}

export var ContactsPage = {
    open: function(){
        L.clickLabel(tr("MainLayout", "bottom_navigation_contacts_label"), 15000);
        snooze(1.5);
    },
    create: function(name, address){
        L.clickNamed("createContactButton", 15000);
        snooze(1.5);
        var nameField = L.waitForNamed("contactEditionGivenName", 15000);
        if (!nameField) test.fatal("Contact editor: first-name field not found");
        L.fill(nameField, name);
        var addressField = L.waitForNamed("contactEditionNewAddress", 10000);
        if (!addressField) test.fatal("Contact editor: SIP address field not found");
        L.fill(addressField, address);
        type(addressField, "<Return>");
        snooze(1);
        L.clickNamed("contactEditionSaveButton", 10000);
        snooze(2);
        if (!entryShowing(name, 20000)) test.fatal("Contact '" + name + "' was not created");
    },
    select: function(name){
        var entry = entryShowing(name, 20000);
        if (!entry) test.fatal("Contact '" + name + "' not found in the list");
        mouseClick(entry);
        snooze(1.5);
    },
    callSelected: function(){
        L.click(tr("ContactPage", "contact_call_action"), 15000);
        snooze(1);
    },
    addSelectedToFavourites: function(){
        var label = tr("ContactPage", "contact_details_add_to_favourites");
        var entry = L.waitForText(label, 5000);
        if (!entry && openMenuWith(label)) entry = L.waitForText(label, 5000);
        if (!entry) test.fatal("'add to favourites' entry not found");
        clickScrolledIntoView(entry);
        snooze(1.5);
        var window = L.waitFor(function(o){return /QQuickApplicationWindow/.test(cnn(o));}, 3000);
        if (window) { try { type(window, "<Escape>"); } catch (e) {} }
        snooze(1);
    },
    selectFavourite: function(name){
        var favourites = L.waitForNamed("favoritesContactList", 20000);
        if (!favourites) test.fatal("Favorites list not displayed");
        var deadline = Date.now() + 20000;
        do {
            var entry = L.textIn(favourites, name);
            if (entry) { mouseClick(entry); snooze(1.5); return; }
            snooze(0.5);
        } while (Date.now() < deadline);
        test.fatal("Contact '" + name + "' not found in the favorites list");
    }
};
