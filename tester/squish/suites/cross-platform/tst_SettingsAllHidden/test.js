import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";
import { WelcomePage } from "welcomePage.js";
import { provisionedAccount } from "serverAccount.js";

function checkAssistant(){
    var ctx = App.launchInstance("set-hidden-assistant");
    App.withInstance(ctx, function(){
        WelcomePage.skipIfPresent();
        test.verify(Settings.shows("LoginPage", "assistant_account_login"), "login page reached (hidden)");
        test.verify(Settings.hides("LoginPage", "assistant_login_third_party_sip_account_title"), "third-party SIP account hidden when assistant_hide_third_party_account=1");
        test.verify(Settings.hides("LoginPage", "assistant_account_register"), "create-account hidden when assistant_hide_create_account=1");
    });
}

function checkMenu(account){
    var ctx = App.launchInstance("set-hidden-menu");
    App.withInstance(ctx, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (menu hidden)");
        test.verify(Settings.hides("MainLayout", "open_conversations_page_accessible_name"), "Conversations tab hidden when disable_chat_feature=1");
        test.verify(Settings.hides("MainLayout", "bottom_navigation_meetings_label"), "Meetings tab hidden when disable_meetings_feature=1");

        test.verify(Settings.openMenuWith(account.username), "account menu opened (hidden)");
        test.verify(Settings.hidesText(account.identity), "SIP address hidden when hide_sip_addresses=1");
        Settings.dismiss();

        test.verify(Settings.openOptionsMenu(), "options menu opened (hidden)");
        test.verify(Settings.hides("MainLayout", "settings_title"), "Settings entry hidden when hide_settings=1");
        test.verify(Settings.hides("MainLayout", "drawer_menu_manage_account"), "My account entry hidden when hide_account_settings=1");
        test.verify(Settings.hides("MainLayout", "recordings_title"), "Records entry hidden when disable_call_recordings=1");
    });
}

function checkSettingsPage(){
    var ctx = App.launchInstance("set-hidden-settings");
    App.withInstance(ctx, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (settings entries hidden)");
        test.verify(Settings.openSettingsPage(), "settings page opened (hidden)");
        test.verify(Settings.hides("SettingsPage", "settings_call_forward"), "Call forward hidden when disable_call_forward=1");
        test.verify(Settings.hides("CallSettingsLayout", "settings_calls_command_line_title"), "Command line hidden when disable_command_line=1");
    });
}

function checkBroadcast(){
    var ctx = App.launchInstance("set-hidden-broadcast");
    App.withInstance(ctx, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (broadcast hidden)");
        Settings.openMeetingForm();
        test.verify(Settings.shows("MeetingPage", "meeting_schedule_title"), "meeting form opened (hidden)");
        test.verify(Settings.hides("MeetingForm", "meeting_schedule_broadcast_label"), "Webinar hidden when disable_broadcast_feature=1");
    });
}

function main(){
    checkAssistant();
    var account = provisionedAccount("B");
    checkMenu(account);
    checkSettingsPage();
    checkBroadcast();
}
