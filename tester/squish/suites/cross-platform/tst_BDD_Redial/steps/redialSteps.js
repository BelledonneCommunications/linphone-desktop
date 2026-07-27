import { DialerPage } from "dialerPage.js";
import { CallWindow } from "callWindow.js";
import { ContactsPage } from "contactsPage.js";
import { HistoryPage } from "historyPage.js";
import { RedialFixture } from "redialFixture.js";
import { provisionedAccount } from "serverAccount.js";

var CONTACT_NAME = "Redial Robot";

function contactAddress(number){
    return "sip:" + number + "@" + provisionedAccount("A").domain;
}

function ensureContact(number){
    ContactsPage.open();
    if (RedialFixture.contactCreated) return;
    ContactsPage.create(CONTACT_NAME, contactAddress(number));
    RedialFixture.contactCreated = true;
}

function backToEmptyDialer(){
    CallWindow.endCallIfAny();
    DialerPage.open();
    DialerPage.clearInput();
}

function callFromContacts(number){
    ensureContact(number);
    ContactsPage.select(CONTACT_NAME);
    ContactsPage.callSelected();
    if (!CallWindow.waitStarted(20000)) test.fatal("Call from contacts did not start");
    CallWindow.endCallIfAny();
}

function callFromFavorites(number){
    ensureContact(number);
    ContactsPage.select(CONTACT_NAME);
    ContactsPage.addSelectedToFavourites();
    ContactsPage.open();
    ContactsPage.selectFavourite(CONTACT_NAME);
    ContactsPage.callSelected();
    if (!CallWindow.waitStarted(20000)) test.fatal("Call from favorites did not start");
    CallWindow.endCallIfAny();
}

function callFromHistory(number){
    callFromContacts(number);
    HistoryPage.open();
    HistoryPage.callEntry([CONTACT_NAME, number]);
    if (!CallWindow.waitStarted(20000)) test.fatal("Call from call history did not start");
    CallWindow.endCallIfAny();
}

Given("the user is on the dialer", function(scenarioContext){
    DialerPage.open();
});

Step("the dialer input is empty", function(scenarioContext){
    test.compare(DialerPage.inputText(), "", "Dialer input is empty");
});

Given("the user has previously dialed the number \"|any|\" manually from the dialer", function(scenarioContext, number){
    DialerPage.dialOnKeypad(number);
    test.compare(DialerPage.inputText(), number, "Number dialed on the keypad");
    DialerPage.pressCallButton();
    if (!CallWindow.startedTo(number, 20000))
        test.fatal("The preparatory manual call to " + number + " did not start");
    backToEmptyDialer();
});

Given("the user has previously called \"|any|\" from |any|", function(scenarioContext, number, origin){
    if (origin === "contacts") callFromContacts(number);
    else if (origin === "favorites") callFromFavorites(number);
    else if (origin === "call history") callFromHistory(number);
    else test.fatal("Unknown call origin in the spec: " + origin);
    backToEmptyDialer();
});

Given("the user has never dialed a number manually from the dialer", function(scenarioContext){
    test.compare(DialerPage.inputText(), "", "Fresh profile: nothing was ever dialed manually");
});

When("the user presses the call button", function(scenarioContext){
    DialerPage.pressCallButton();
});

When("the user changes the dialer input to \"|any|\"", function(scenarioContext, number){
    DialerPage.setInput(number);
});

Then("the dialer input contains \"|any|\"", function(scenarioContext, number){
    test.compare(DialerPage.inputText(), number, "Dialer input recalled the last dialed number");
});

Then("no call is started", function(scenarioContext){
    test.verify(CallWindow.stayedAbsent(5000), "No call window appeared");
});

Then("a call is started to \"|any|\"", function(scenarioContext, number){
    test.verify(CallWindow.startedTo(number, 20000), "A call is started to " + number);
    CallWindow.endCallIfAny();
});
