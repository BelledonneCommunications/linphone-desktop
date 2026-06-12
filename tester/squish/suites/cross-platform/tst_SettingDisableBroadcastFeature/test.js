import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";
import * as L from "squishlib.js";
import { tr } from "translate.js";

var FEATURE = "meeting_schedule_broadcast_label";
var ANCHOR = "meeting_schedule_title";

function openMeetingForm(){
    L.clickLabel(tr("bottom_navigation_meetings_label"), 10000);
    snooze(2);
    L.clickLabel(tr("meetings_add"), 8000);
    snooze(2);
}

function main(){
    var shown = App.launchInstance("set-bc-show");
    var hidden = App.launchInstance("set-bc-hide");

    App.withInstance(shown, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (broadcast shown)");
        openMeetingForm();
        test.verify(Settings.shows(ANCHOR), "meeting form opened (shown)");
        test.verify(Settings.shows(FEATURE), "Webinar shown when disable_broadcast_feature=0");
    });
    App.withInstance(hidden, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (broadcast hidden)");
        openMeetingForm();
        test.verify(Settings.shows(ANCHOR), "meeting form opened (hidden)");
        test.verify(Settings.hides(FEATURE), "Webinar hidden when disable_broadcast_feature=1");
    });
}
