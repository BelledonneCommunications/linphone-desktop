import * as L from "squishlib.js";
import { tr } from "translate.js";

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
    shows: function(key, t){ return Settings.showsText(tr(key), t); },
    hides: function(key, t){ return Settings.hidesText(tr(key), t); },
    openMenuWith: function(text){ return openMenuWith(text); },
    openOptionsMenu: function(){
        return openMenuWith(tr("contact_presence_status_enable_do_not_disturb"))
            || openMenuWith(tr("contact_presence_status_disable_do_not_disturb"));
    },
    openSettingsPage: function(){
        if(!Settings.openOptionsMenu()) return false;
        L.clickLabel(tr("settings_title"), 8000);
        snooze(2);
        return true;
    }
};
