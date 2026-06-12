import * as L from "squishlib.js";
import { tr } from "translate.js";

export var SipLoginPage = {
    acknowledgeWarning: function(){
        L.click(tr("SIPLoginPage", "assistant_third_party_sip_account_warning_ok"), 15000);
    },
    login: function(account){
        var fields = L.textFields(20000);
        if (fields.length < 3) test.fatal("SIP login form not ready (found " + fields.length + " fields)");
        var usernameField = fields[0];
        var passwordField = fields[1];
        var domainField = fields[2];
        L.fill(usernameField, account.username);
        L.fill(passwordField, account.password);
        L.fill(domainField, account.domain);
        L.selectInDropdown("TCP", 5000);
        L.click(tr("SIPLoginPage", "assistant_account_login"), 15000);
    }
};
