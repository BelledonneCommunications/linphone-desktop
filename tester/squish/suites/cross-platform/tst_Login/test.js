import { App } from "app.js";
import { WelcomePage } from "welcomePage.js";
import { LoginPage } from "loginPage.js";
import { SipLoginPage } from "sipLoginPage.js";
import { MainPage } from "mainPage.js";
import { provisionedAccount } from "serverAccount.js";

function main(){
    var account = provisionedAccount();
    test.log("login as "+account.identity);

    App.launch();
    WelcomePage.skipIfPresent();
    LoginPage.openThirdPartySipAccount();
    SipLoginPage.acknowledgeWarning();
    SipLoginPage.login(account);

    test.verify(MainPage.waitLoaded(), "Logged in: main navigation visible");
}
