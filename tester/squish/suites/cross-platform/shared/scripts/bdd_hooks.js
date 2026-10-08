import { RedialFixture } from "redialFixture.js";
import { A11yFixture } from "a11yFixture.js";

var A11Y_TEST_CASES = ["tst_BDD_KeyboardActivation", "tst_BDD_MenuFocus", "tst_BDD_ConversationListKeyboard", "tst_BDD_CallPanelFocus", "tst_BDD_KeyboardAccess"];

function currentTestCaseIs(name){
    try { return String(squishinfo.testCase).indexOf(name) >= 0; } catch (e) { return false; }
}

OnScenarioStart(function(context){
    if (currentTestCaseIs("tst_BDD_Redial")) RedialFixture.startScenario();
});

OnScenarioEnd(function(context){
    if (currentTestCaseIs("tst_BDD_Redial")) RedialFixture.endScenario();
    if (A11Y_TEST_CASES.some(currentTestCaseIs)) A11yFixture.endScenario();
});
