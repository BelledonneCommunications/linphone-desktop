import { T } from "currentTranslations.js";

function lookupInContext(context, key){
    var entries = T[context];
    if (entries && entries[key] !== undefined && entries[key] !== "") return entries[key];
    return undefined;
}

function lookupAnywhere(key){
    for (var context in T) {
        var value = T[context][key];
        if (value !== undefined && value !== "") return value;
    }
    return undefined;
}

export function tr(context, key){
    if (key === undefined) { key = context; context = null; }
    var value = context ? lookupInContext(context, key) : undefined;
    if (value === undefined) value = lookupAnywhere(key);
    return value === undefined ? key : value;
}
