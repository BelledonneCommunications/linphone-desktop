import * as L from "squishlib.js";
import { tr } from "translate.js";
import { App } from "app.js";

function cnn(o){try{return className(o);}catch(e){return "";}}
function tx(o){try{return o.text?String(o.text):"";}catch(e){return "";}}

function popupButtons(){
    return L.findAll(function(o){return o.visible&&/PopupButton_QMLTYPE/.test(cnn(o));});
}

function openMenuWith(text){
    var pbs=popupButtons();
    for(var i=0;i<pbs.length;i++){
        mouseClick(pbs[i]); snooze(1.5);
        if(L.waitFor(function(o){return o.visible&&tx(o)===text;},2500)) return true;
        try{type(pbs[i], "<Escape>");}catch(e){}
        snooze(0.5);
    }
    return false;
}

export var Settings = {
    showsText: function(text, t){
        return L.waitFor(function(o){return o.visible&&tx(o)===text;}, t||15000)!=null;
    },
    hidesText: function(text, t){
        return !L.waitFor(function(o){return o.visible&&tx(o)===text;}, t||6000);
    },
    shows: function(context, key, t){ return Settings.showsText(tr(context, key), t); },
    hides: function(context, key, t){ return Settings.hidesText(tr(context, key), t); },
    openMenuWith: function(text){ return openMenuWith(text); },
    openOptionsMenu: function(){
        return openMenuWith(tr("MainLayout", "contact_presence_status_enable_do_not_disturb"))
            || openMenuWith(tr("MainLayout", "contact_presence_status_disable_do_not_disturb"));
    },
    openSettingsPage: function(){
        if(!Settings.openOptionsMenu()) return false;
        return Settings.openSettingsFromMenu();
    },
    openSettingsFromMenu: function(){
        L.click(tr("MainLayout", "settings_title"), 8000);
        snooze(2);
        return true;
    },
    openMeetingForm: function(){
        for (var attempt = 0; attempt < 3; attempt++) {
            L.clickNamed("mainTab3", 10000);
            snooze(2);
            var meetingsTab = L.waitForNamed("mainTab3", 2000);
            if (meetingsTab && meetingsTab.checked) break;
            L.clickIfVisible(tr("MainLayout", "contact_editor_dialog_abort_confirmation_do_not_save"), 5000);
        }
        var addLabel = tr("MeetingPage", "meetings_add");
        var addButton = L.waitFor(function(o){
            try {
                if (!o.visible) return false;
                if (String(o.objectName) === "newMeetingButton") return true;
                return /BigButton/.test(className(o)) && String(o.text) === addLabel;
            } catch (e) { return false; }
        }, 30000);
        if (!addButton) {
            var tab = L.waitForNamed("mainTab3", 1000);
            var shown = L.findAll(function(o){
                try { return o.visible && o.text && String(o.text).length > 0; } catch (e) { return false; }
            }).map(function(o){ return String(o.text).substring(0, 40); });
            test.log("Meetings tab checked: " + (tab ? tab.checked : "not found") + ", visible texts: " + shown.slice(0, 60).join(" | "));
            try { test.attachDesktopScreenshot("Meetings page without a create button"); } catch (e) {}
            test.fatal("No button to create a meeting on the meetings page");
            return false;
        }
        mouseClick(addButton);
        snooze(2);
        return true;
    },
    dismiss: function(){
        var w = App.window(3000);
        if(w){ try{type(w, "<Escape>");}catch(e){} snooze(1); }
        return true;
    }
};
