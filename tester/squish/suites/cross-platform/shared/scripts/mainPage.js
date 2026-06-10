import * as L from "squishlib.js";

export var MainPage = {
    waitLoaded: function(t){ return L.hasType(/TabButton/, t||90000); }
};
