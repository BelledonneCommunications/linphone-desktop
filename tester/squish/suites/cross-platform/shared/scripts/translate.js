import { T } from "currentTranslations.js";

export function tr(key){
    var value = T[key];
    return (value === undefined || value === "") ? key : value;
}
