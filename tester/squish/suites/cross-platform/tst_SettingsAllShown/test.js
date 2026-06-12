import { App } from "app.js";
import { MainPage } from "mainPage.js";
import { Settings } from "settingsPage.js";
import { WelcomePage } from "welcomePage.js";
import { provisionedAccount } from "serverAccount.js";

function checkAssistant(){
    var ctx = App.launchInstance("set-shown-assistant");
    App.withInstance(ctx, function(){
        WelcomePage.skipIfPresent();
        test.verify(Settings.shows("LoginPage", "assistant_account_login"), "login page reached (shown)");
        test.verify(Settings.shows("LoginPage", "assistant_login_third_party_sip_account_title"), "third-party SIP account shown when assistant_hide_third_party_account=0");
        test.verify(Settings.shows("LoginPage", "assistant_account_register"), "create-account shown when assistant_hide_create_account=0");
    });
}

function checkLoggedIn(){
    var account = provisionedAccount("A");
    var ctx = App.launchInstance("set-shown");
    App.withInstance(ctx, function(){
        test.verify(MainPage.waitLoaded(), "main loaded (shown)");
        test.verify(Settings.shows("MainLayout", "open_conversations_page_accessible_name"), "Conversations tab shown when disable_chat_feature=0");
        test.verify(Settings.shows("MainLayout", "bottom_navigation_meetings_label"), "Meetings tab shown when disable_meetings_feature=0");

        test.verify(Settings.openMenuWith(account.username), "account menu opened (shown)");
        test.verify(Settings.showsText(account.identity), "SIP address shown when hide_sip_addresses=0");
        Settings.dismiss();

        test.verify(Settings.openOptionsMenu(), "options menu opened (shown)");
        test.verify(Settings.shows("MainLayout", "settings_title"), "Settings entry shown when hide_settings=0");
        test.verify(Settings.shows("MainLayout", "drawer_menu_manage_account"), "My account entry shown when hide_account_settings=0");
        test.verify(Settings.shows("MainLayout", "recordings_title"), "Records entry shown when disable_call_recordings=0");

        test.verify(Settings.openSettingsFromMenu(), "settings page opened (shown)");
        test.verify(Settings.shows("SettingsPage", "settings_call_forward"), "Call forward shown when disable_call_forward=0");
        test.verify(Settings.shows("CallSettingsLayout", "settings_calls_command_line_title"), "Command line shown when disable_command_line=0");
        Settings.dismiss();

        Settings.openMeetingForm();
        test.verify(Settings.shows("MeetingPage", "meeting_schedule_title"), "meeting form opened (shown)");
        test.verify(Settings.shows("MeetingForm", "meeting_schedule_broadcast_label"), "Webinar shown when disable_broadcast_feature=0");
    });
}

function main(){
    checkAssistant();
    checkLoggedIn();
}
