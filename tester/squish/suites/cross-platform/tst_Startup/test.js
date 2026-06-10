import { App } from "app.js";

function main(){
    App.launch();
    test.verify(App.windowVisible(30000), "Linphone main window appeared");
}
