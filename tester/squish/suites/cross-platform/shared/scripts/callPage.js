import * as L from "squishlib.js";
import { tr } from "translate.js";

function cnn(o){try{return className(o);}catch(e){return "";}}
function tx(o){try{return o.text?String(o.text):"";}catch(e){return "";}}
function ph(o){try{return o.placeholderText?String(o.placeholderText):"";}catch(e){return "";}}

export var CallPage = {
    open: function(){
        L.click(tr("MainLayout", "open_calls_page_accessible_name"), 15000);
        snooze(1);
    },
    callBySip: function(account){
        L.click(tr("CallPage", "call_action_start_new_call"), 10000);
        snooze(1);
        var placeholder = tr("CreationFormLayout", "search_bar_look_for_contact_text");
        var field=L.waitFor(function(o){return /TextField/.test(cnn(o))&&o.visible&&ph(o)===placeholder;},10000);
        if(!field) test.fatal("New-call search field not found");
        L.fill(field, account.identity);
        snooze(2);
        var row=L.waitFor(function(o){return o.visible&&tx(o).indexOf(account.username)>=0&&/Text_QMLTYPE/.test(cnn(o));},10000);
        if(!row) test.fatal("Call suggestion for "+account.identity+" not found");
        mouseClick(row);
        snooze(2);
    },
    accept: function(){
        L.click(tr("NotificationReceivedCall", "dialog_accept"), 20000);
        snooze(1);
    },
    waitConnected: function(t){
        return L.waitFor(function(o){return o.visible&&/^[0-9][0-9]:[0-9][0-9]$/.test(tx(o));}, t||25000)!=null;
    }
};
