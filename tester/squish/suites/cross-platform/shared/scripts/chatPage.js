import * as L from "squishlib.js";
import { tr } from "translate.js";

function cnn(o){try{return className(o);}catch(e){return "";}}
function ph(o){try{return o.placeholderText?String(o.placeholderText):"";}catch(e){return "";}}
function tx(o){try{return o.text?String(o.text):"";}catch(e){return "";}}

export var ChatPage = {
    open: function(){
        L.click(tr("MainLayout", "open_conversations_page_accessible_name"), 15000);
        snooze(1);
    },
    startChatWith: function(account){
        L.click(tr("ChatPage", "chat_start_title"), 10000);
        snooze(1);
        var placeholder = tr("CreationFormLayout", "search_bar_look_for_contact_text");
        var field=L.waitFor(function(o){return /TextField/.test(cnn(o))&&o.visible&&ph(o)===placeholder;},10000);
        if(!field) test.fatal("New-chat search field not found");
        L.fill(field, account.identity);
        snooze(2);
        var row=L.waitFor(function(o){return o.visible&&tx(o).indexOf(account.username)>=0&&/Text_QMLTYPE/.test(cnn(o));},10000);
        if(!row) test.fatal("Suggestion row for "+account.identity+" not found");
        mouseClick(row);
        snooze(2);
    },
    openConversationWith: function(account){
        var row=L.waitFor(function(o){return o.visible&&tx(o).indexOf(account.username)>=0&&/Text_QMLTYPE/.test(cnn(o));},30000);
        if(!row) test.fatal("Conversation with "+account.username+" not found");
        mouseClick(row);
        snooze(2);
    },
    sendMessage: function(message){
        var placeholder = tr("ChatDroppableTextArea", "chat_view_send_area_placeholder_text");
        var area=L.waitFor(function(o){return /TextArea/.test(cnn(o))&&o.visible&&ph(o)===placeholder;},10000);
        if(!area) test.fatal("Message input not found");
        mouseClick(area);
        type(area, message);
        type(area, "<Return>");
        snooze(1);
    },
    waitForMessage: function(message, t){
        return L.waitFor(function(o){return o.visible&&tx(o).indexOf(message)>=0;}, t||30000)!=null;
    }
};
