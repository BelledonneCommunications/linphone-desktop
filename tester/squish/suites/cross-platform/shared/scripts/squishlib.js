function classOf(element){
    try { return className(element); } catch (e) { return ""; }
}

function textOf(element){
    try { return element.text ? String(element.text) : ""; } catch (e) { return ""; }
}

function onScreen(element){
    try { return element.visible; } catch (e) { return false; }
}

export function findAll(matches){
    var found = [];
    function visit(element){
        try { if (matches(element)) found.push(element); } catch (e) {}
        var children = [];
        try { children = object.children(element); } catch (e) { return; }
        for (var i = 0; i < children.length; i++) visit(children[i]);
    }
    var windows = findAllObjects({ "type": "QQuickWindow" });
    for (var w = 0; w < windows.length; w++) visit(windows[w]);
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

export function clickLabel(text, timeoutMs){ return click(text, timeoutMs); }
export function comboPick(value, timeoutMs){ return selectInDropdown(value, timeoutMs); }
export function hasType(typePattern, timeoutMs){ return hasControlType(typePattern, timeoutMs); }
