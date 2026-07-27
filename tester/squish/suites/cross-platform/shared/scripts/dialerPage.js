import * as L from "squishlib.js";
import { tr } from "translate.js";

var SEARCH_BAR_INPUT = "newCallSearchBarInput";
var SEARCH_BAR_DIALER_BUTTON = "newCallSearchBarDialerButton";
var KEYPAD = "numericPadPopup";
var CALL_BUTTON = "numericPadCallButton";
var ERASE_BUTTON = "numericPadEraseButton";

function inputField(timeoutMs){
    return L.waitForNamed(SEARCH_BAR_INPUT, timeoutMs || 15000);
}

function keypadOpened(timeoutMs){
    return L.waitForNamed(CALL_BUTTON, timeoutMs || 5000) !== null;
}

export var DialerPage = {
    open: function(){
        L.click(tr("MainLayout", "open_calls_page_accessible_name"), 15000);
        snooze(1);
        if (!inputField(3000)) {
            L.clickNamed("createNewCallButton", 15000);
            snooze(1);
        }
        if (!inputField(15000)) test.fatal("Dialer not reached: new-call search field not found");
        DialerPage.openKeypad();
    },
    openKeypad: function(){
        if (keypadOpened(3000)) return true;
        if (!L.clickNamed(SEARCH_BAR_DIALER_BUTTON, 10000)) return false;
        snooze(1);
        if (!keypadOpened(10000)) test.fatal("Numeric pad did not open");
        return true;
    },
    inputText: function(){
        var field = inputField(10000);
        if (!field) test.fatal("Dialer input not found");
        try { return field.text ? String(field.text) : ""; } catch (e) { return ""; }
    },
    clearInput: function(){
        var field = inputField(10000);
        if (!field) test.fatal("Dialer input not found");
        mouseClick(field);
        type(field, "<Ctrl+a>");
        type(field, "<Delete>");
        snooze(0.5);
        var guard = 0;
        while (DialerPage.inputText().length > 0 && guard < 40) {
            L.clickNamed(ERASE_BUTTON, 5000);
            guard = guard + 1;
        }
    },
    dialOnKeypad: function(number){
        DialerPage.openKeypad();
        for (var i = 0; i < number.length; i++) {
            var key = number.charAt(i);
            if (!L.clickNamed("numericPadKey" + key, 10000))
                test.fatal("Numeric pad has no key for '" + key + "'");
            snooze(0.2);
        }
        snooze(0.5);
    },
    setInput: function(number){
        var field = inputField(10000);
        if (!field) test.fatal("Dialer input not found");
        L.fill(field, number);
        snooze(0.5);
    },
    pressCallButton: function(){
        DialerPage.openKeypad();
        L.clickNamed(CALL_BUTTON, 10000);
        snooze(1);
    }
};
