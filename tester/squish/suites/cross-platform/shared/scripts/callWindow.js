import * as L from "squishlib.js";

var WINDOW = "callsWindow";
var END_CALL_BUTTON = "endCallButton";

function remoteAddressOf(window){
    var deadline = Date.now() + 10000;
    do {
        try {
            var address = window.call.core.remoteAddress;
            if (address) return String(address);
        } catch (e) {}
        snooze(0.5);
    } while (Date.now() < deadline);
    return null;
}

export var CallWindow = {
    waitStarted: function(timeoutMs){
        return L.waitForWindowNamed(WINDOW, timeoutMs || 20000);
    },
    startedTo: function(number, timeoutMs){
        var window = CallWindow.waitStarted(timeoutMs);
        if (!window) return false;
        var address = remoteAddressOf(window);
        if (address !== null) {
            test.log("Call window remote address: " + address);
            return address.indexOf(number) >= 0;
        }
        test.log("Remote address property unreadable, falling back to on-screen text");
        var deadline = Date.now() + 10000;
        do {
            if (L.containsText(window, number)) return true;
            snooze(0.5);
        } while (Date.now() < deadline);
        return false;
    },
    stayedAbsent: function(timeoutMs){
        var deadline = Date.now() + (timeoutMs || 5000);
        do {
            if (L.waitForWindowNamed(WINDOW, 500)) return false;
            snooze(0.5);
        } while (Date.now() < deadline);
        return true;
    },
    endCallIfAny: function(){
        var window = L.waitForWindowNamed(WINDOW, 1500);
        if (!window) return;
        var button = L.namedIn(window, END_CALL_BUTTON);
        if (button) {
            // The call can end on its own (SIP error) between the lookup and the click.
            try { mouseClick(button); } catch (e) {}
            snooze(1);
        }
        L.waitWindowNamedGone(WINDOW, 20000);
    }
};
