import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { provisionedAccount } from "serverAccount.js";

function main(){
    var accountA = provisionedAccount("A");
    var accountB = provisionedAccount("B");
    test.log("A="+accountA.identity+" B="+accountB.identity);

    var ctxA = App.launchInstance("a");
    var ctxB = App.launchInstance("b");

    var okA = App.withInstance(ctxA, function(){ return MainPage.waitLoaded(); });
    var okB = App.withInstance(ctxB, function(){ return MainPage.waitLoaded(); });

    test.verify(okA, "Instance A came up on its own account: "+accountA.identity);
    test.verify(okB, "Instance B came up on its own account: "+accountB.identity);
}
