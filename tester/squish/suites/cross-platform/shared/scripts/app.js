export var App = {
    window: function(t){
        var end=Date.now()+(t||30000);
        do{ var r=findAllObjects({"type":"QQuickApplicationWindow"}); if(r&&r.length)return r[0]; snooze(0.5); }while(Date.now()<end);
        return null;
    },
    launch: function(){ startApplication("Linphone"); snooze(1); },
    launchInstance: function(id){ var ctx=startApplication("Linphone --test-instance "+id); snooze(1); return ctx; },
    withInstance: function(ctx, fn){ setApplicationContext(ctx); return fn(); },
    windowVisible: function(t){ return App.window(t)!=null; }
};
