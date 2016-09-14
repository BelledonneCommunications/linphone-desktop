// ===================================================================
// Contains many common helpers.
// ===================================================================

function openWindow (windowName, parent) {
    var component = Qt.createComponent(
        'qrc:/ui/views/' + windowName + '.qml'
    );

    if (component.status !== Component.Ready) {
        console.debug('Window ' + windowName + ' not ready.')
        if(component.status === Component.Error) {
            console.debug('Error:' + component.errorString())
        }
    } else {
        component.createObject(parent).show()
    }
}
