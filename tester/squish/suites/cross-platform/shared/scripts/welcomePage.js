import * as L from "squishlib.js";
import { tr } from "translate.js";

export var WelcomePage = {
    skipIfPresent: function(){
        if (L.clickIfVisible(tr("WelcomePage", "welcome_carousel_skip"), 15000)) snooze(1);
    }
};
