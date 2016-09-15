// ===================================================================
// Contains many common helpers.
// ===================================================================

// Load by default a window in the ui/views folder.
// If options.isString is equals to true, a marshalling component can
// be used.
//
// Supported options: isString, exitHandler.
//
// If exitHandler is used, window must implement returnedValue
// signal.
function openWindow (window, parent, options) {
    var object
    if (options && options.isString) {
        object = Qt.createQmlObject(window, parent)
    } else {
        var component = Qt.createComponent(
            'qrc:/ui/views/' + window + '.qml'
        )

        if (component.status !== Component.Ready) {
            console.debug('Window not ready.')
            if(component.status === Component.Error) {
                console.debug('Error:' + component.errorString())
            }
            return // Error.
        }

        object = component.createObject(parent)
    }

    console.debug('Open window.')

    object.closing.connect(function () {
        console.debug('Destroy window.')
        object.destroy()
    })

    if (options && options.exitHandler) {
        object.exitStatus.connect(
            // Bind to access parent properties.
            options.exitHandler.bind(parent)
        )
    }
    object.show()
}

// -------------------------------------------------------------------

// Display a simple ConfirmDialog component. Wrap the openWindow function.
function openConfirmDialog (parent, options) {
    openWindow(
        'import QtQuick 2.7;' +
        'import \'qrc:/ui/components/dialog\';' +
        'ConfirmDialog {' +
        'descriptionText: \'' + options.descriptionText + '\';' +
        'title: \'' + options.title + '\'' +
        '}',
        parent, {
            isString: true,
            exitHandler: options.exitHandler
        }
    )
}
