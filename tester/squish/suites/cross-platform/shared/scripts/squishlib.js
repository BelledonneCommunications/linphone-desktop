function classOf(element){
    try { return className(element); } catch (e) { return ""; }
}

function textOf(element){
    try { return element.text ? String(element.text) : ""; } catch (e) { return ""; }
}

function onScreen(element){
    try { return element.visible; } catch (e) { return false; }
}

function nameOf(element){
    try { return element.objectName ? String(element.objectName) : ""; } catch (e) { return ""; }
}

function findAllIn(root, matches){
    var found = [];
    function visit(element){
        try { if (matches(element)) found.push(element); } catch (e) {}
        var children = [];
        try { children = object.children(element); } catch (e) { return; }
        for (var i = 0; i < children.length; i++) visit(children[i]);
    }
    visit(root);
    return found;
}

function topLevelWindows(){
    try { return findAllObjects({ "type": "QQuickWindow" }); } catch (e) { return []; }
}

export function findAll(matches){
    var found = [];
    var windows = topLevelWindows();
    for (var w = 0; w < windows.length; w++) found = found.concat(findAllIn(windows[w], matches));
    return found;
}

export function waitFor(matches, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 20000);
    do {
        var found = findAll(matches);
        if (found.length > 0) return found[0];
        snooze(0.5);
    } while (Date.now() < deadline);
    return null;
}

export function waitGone(matches, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 30000);
    do {
        if (findAll(matches).length === 0) return true;
        snooze(1);
    } while (Date.now() < deadline);
    return false;
}

function showingText(text){
    return function(element){ return onScreen(element) && textOf(element) === text; };
}

function looksLikeButton(element){
    return /BigButton|SmallButton|Button_QMLTYPE/.test(classOf(element));
}

function enclosingButton(element){
    var current = element;
    for (var i = 0; i < 10; i++) {
        try { current = object.parent(current); } catch (e) { return null; }
        if (!current) return null;
        if (looksLikeButton(current)) return current;
    }
    return null;
}

export function waitForText(text, timeoutMs){
    return waitFor(showingText(text), timeoutMs);
}

export function isVisible(text, timeoutMs){
    return waitForText(text, timeoutMs || 15000) !== null;
}

export function isHidden(text, timeoutMs){
    return waitForText(text, timeoutMs || 6000) === null;
}

export function click(text, timeoutMs){
    var button = waitFor(function(element){
        return looksLikeButton(element) && onScreen(element) && textOf(element) === text;
    }, timeoutMs);
    if (button) { mouseClick(button); return true; }

    var label = waitFor(function(element){
        return onScreen(element) && textOf(element) === text && enclosingButton(element) !== null;
    }, 3000);
    if (label) { mouseClick(enclosingButton(label)); return true; }

    test.fatal("No clickable element labelled: " + text);
    return false;
}

export function clickIfVisible(text, timeoutMs){
    var button = waitFor(function(element){
        return looksLikeButton(element) && onScreen(element) && textOf(element) === text;
    }, timeoutMs || 8000);
    if (button) { mouseClick(button); return true; }
    return false;
}

export function textFields(timeoutMs){
    function isTextField(element){ return /TextField/.test(classOf(element)) && onScreen(element); }
    if (!waitFor(isTextField, timeoutMs)) return [];
    return findAll(isTextField);
}

export function fill(field, value){
    mouseClick(field);
    type(field, "<Ctrl+a>");
    type(field, value);
}

export function selectInDropdown(value, timeoutMs){
    var dropdown = waitFor(function(element){
        return /ComboBox/.test(classOf(element)) && onScreen(element);
    }, timeoutMs);
    if (!dropdown) return false;
    mouseClick(dropdown);
    snooze(1);
    var item = waitForText(value, 4000);
    if (item) { mouseClick(item); return true; }
    return false;
}

export function hasControlType(typePattern, timeoutMs){
    return waitFor(function(element){
        return typePattern.test(classOf(element)) && onScreen(element);
    }, timeoutMs) !== null;
}

function named(name){
    return function(element){ return nameOf(element) === name && onScreen(element); };
}

// The AUT resolves objectName in a single call, where the tree walk costs one round-trip per
// object and per property. Which one works is decided on first success, then kept.
var useNativeLookup = null;

function nativelyShownWithName(name){
    var matches = [];
    try { matches = findAllObjects({ "objectName": name }); } catch (e) { return []; }
    var shown = [];
    for (var i = 0; i < matches.length; i++) if (onScreen(matches[i])) shown.push(matches[i]);
    return shown;
}

function shownWithName(name){
    if (useNativeLookup !== false) {
        var found = nativelyShownWithName(name);
        if (found.length > 0) { useNativeLookup = true; return found; }
        if (useNativeLookup === true) return [];
    }
    var walked = findAll(named(name));
    if (walked.length > 0) useNativeLookup = false;
    return walked;
}

export function waitForNamed(name, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 15000);
    do {
        var found = shownWithName(name);
        if (found.length > 0) return found[0];
        snooze(0.5);
    } while (Date.now() < deadline);
    return null;
}

export function namedIn(root, name){
    var found = findAllIn(root, named(name));
    return found.length > 0 ? found[0] : null;
}

export function allNamed(name){
    return shownWithName(name);
}

export function clickNamed(name, timeoutMs){
    var element = waitForNamed(name, timeoutMs);
    if (!element) { test.fatal("No visible element with objectName: " + name); return false; }
    mouseClick(element);
    return true;
}

export function textIn(root, text){
    var found = findAllIn(root, function(element){ return onScreen(element) && textOf(element) === text; });
    return found.length > 0 ? found[0] : null;
}

export function containsText(root, fragment){
    var found = findAllIn(root, function(element){
        return onScreen(element) && textOf(element).indexOf(fragment) >= 0;
    });
    return found.length > 0 ? found[0] : null;
}

function shownWindowNamed(name){
    var windows = topLevelWindows();
    for (var i = 0; i < windows.length; i++)
        if (nameOf(windows[i]) === name && onScreen(windows[i])) return windows[i];
    return null;
}

export function waitForWindowNamed(name, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 20000);
    do {
        var window = shownWindowNamed(name);
        if (window) return window;
        snooze(0.5);
    } while (Date.now() < deadline);
    return null;
}

export function waitWindowNamedGone(name, timeoutMs){
    var deadline = Date.now() + (timeoutMs || 20000);
    do {
        if (!shownWindowNamed(name)) return true;
        snooze(0.5);
    } while (Date.now() < deadline);
    return false;
}

export function clickLabel(text, timeoutMs){ return click(text, timeoutMs); }
export function comboPick(value, timeoutMs){ return selectInDropdown(value, timeoutMs); }
export function hasType(typePattern, timeoutMs){ return hasControlType(typePattern, timeoutMs); }
