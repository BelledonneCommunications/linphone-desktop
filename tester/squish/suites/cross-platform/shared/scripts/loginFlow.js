import { WelcomePage } from "welcomePage.js";
import { LoginPage } from "loginPage.js";
import { SipLoginPage } from "sipLoginPage.js";
import { MainPage } from "mainPage.js";

export function loginThirdParty(account){
    WelcomePage.skipIfPresent();
    LoginPage.openThirdPartySipAccount();
    SipLoginPage.acknowledgeWarning();
    SipLoginPage.login(account);
    return MainPage.waitLoaded();
}
