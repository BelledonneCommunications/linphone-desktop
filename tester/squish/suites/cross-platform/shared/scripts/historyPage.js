import * as L from "squishlib.js";
import { tr } from "translate.js";

export var HistoryPage = {
    open: function(){
        L.click(tr("MainLayout", "open_calls_page_accessible_name"), 15000);
        snooze(1.5);
    },
    callEntry: function(candidates){
        var deadline = Date.now() + 30000;
        do {
            var entries = L.allNamed("callHistoryEntry");
            for (var i = 0; i < entries.length; i++) {
                var matches = false;
                for (var c = 0; c < candidates.length; c++)
                    if (L.containsText(entries[i], candidates[c])) matches = true;
                if (!matches) continue;
                var button = L.namedIn(entries[i], "callHistoryCallButton");
                if (button) { mouseClick(button); snooze(1); return; }
            }
            snooze(1);
        } while (Date.now() < deadline);
        test.fatal("No call history entry for '" + candidates.join("' / '") + "'");
    }
};
