import { RedialFixture } from "redialFixture.js";
import { A11yFixture } from "a11yFixture.js";

function currentTestCaseIs(name){
    try { return String(squishinfo.testCase).indexOf(name) >= 0; } catch (e) { return false; }
}

OnScenarioStart(function(context){
    if (currentTestCaseIs("tst_BDD_Redial")) RedialFixture.startScenario();
});

OnScenarioEnd(function(context){
    if (currentTestCaseIs("tst_BDD_Redial")) RedialFixture.endScenario();
    if (currentTestCaseIs("tst_BDD_KeyboardActivation") || currentTestCaseIs("tst_BDD_MenuFocus")) A11yFixture.endScenario();
});
