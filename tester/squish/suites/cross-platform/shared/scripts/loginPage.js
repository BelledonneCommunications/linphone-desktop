import * as L from "squishlib.js";
import { tr } from "translate.js";

export var LoginPage = {
    openThirdPartySipAccount: function(){
        L.click(tr("LoginPage", "assistant_login_third_party_sip_account_title"), 20000);
    }
};
