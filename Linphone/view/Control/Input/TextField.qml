import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import Linphone
import "qrc:/qt/qml/Linphone/view/Style/buttonStyle.js" as ButtonStyle

Control.TextField {
    id: mainItem
    property var customWidth
    width: Math.round((customWidth ? customWidth - 1 : 360) * DefaultStyle.dp)
    height: Math.round(49 * DefaultStyle.dp)
    leftPadding: Math.round(15 * DefaultStyle.dp)
    rightPadding: eyeButton.visible
        ? Math.round(5 * DefaultStyle.dp) + eyeButton.width + eyeButton.rightMargin
        : Math.round(15 * DefaultStyle.dp)
    echoMode: (hidden && !eyeButton.checked) ? TextInput.Password : TextInput.Normal

    // Workaround for Windows slowness when first typing a password
    // due to Qt not initializing the Password echo mode before the first letter is typed
    Component.onCompleted: {
        text = "workaround"
        resetText()
    }

    verticalAlignment: TextInput.AlignVCenter
    color: isError ? DefaultStyle.danger_500main : DefaultStyle.main2_600
    placeholderTextColor: DefaultStyle.placeholders
    font {
        family: DefaultStyle.defaultFont
        pixelSize: Typography.p1.pixelSize
        weight: Typography.p1.weight
    }
    selectByMouse: true
    activeFocusOnTab: true
    KeyNavigation.right: eyeButton
    text: initialText

    property bool controlIsDown: false
    property bool hidden: false
    property bool isError: false
    property bool backgroundVisible: true
    property color backgroundColor: DefaultStyle.grey_100
    property color disabledBackgroundColor: DefaultStyle.grey_200
    property color backgroundBorderColor: DefaultStyle.grey_200
    property string initialText
    property real pixelSize: Typography.p1.pixelSize
    property real weight: Typography.p1.weight

    // fill propertyName and propertyOwner to check text validity
    property string propertyName
    property var propertyOwner
    property var propertyOwnerGui
    property var initialReading: true
    property var isValid: function (text) {
        return true
    }
    property bool toValidate: false
    property int idleTimeOut: 200
    property bool empty: propertyOwnerGui
        ? mainItem.propertyOwnerGui.core != undefined && mainItem.propertyOwnerGui.core[mainItem.propertyName]?.length == 0
        : mainItem.propertyOwner != undefined && mainItem.propertyOwner[mainItem.propertyName]?.length == 0
    property bool canBeEmpty: true

    signal validationChecked(bool valid)

    function resetText() {
        text = initialText
    }

    signal enterPressed

    onAccepted: {
        // No need to process changing focus because of TextEdited callback.
        idleTimer.stop()
        updateText()
    }
    onTextEdited: {
        if (mainItem.toValidate) {
            idleTimer.restart()
        }
    }
    function updateText() {
        mainItem.empty = text.length == 0
        if (initialReading) {
            initialReading = false
        }
        if (mainItem.empty && !mainItem.canBeEmpty) {
            mainItem.validationChecked(false)
            return
        }
        if (mainItem.propertyName && isValid(text)) {
            if (mainItem.propertyOwnerGui) {
                if (mainItem.propertyOwnerGui.core[mainItem.propertyName] != text)
                    mainItem.propertyOwnerGui.core[mainItem.propertyName] = text
            } else {
                if (mainItem.propertyOwner[mainItem.propertyName] != text)
                    mainItem.propertyOwner[mainItem.propertyName] = text
            }
            mainItem.validationChecked(true)
        } else
            mainItem.validationChecked(false)
    }
    // Validation textfield functions
    Timer {
        id: idleTimer
        running: false
        interval: mainItem.idleTimeOut
        repeat: false
        onTriggered: {
            mainItem.accepted()
        }
    }

    background: Rectangle {
        id: inputBackground
        visible: mainItem.backgroundVisible
        anchors.fill: parent
        radius: Math.round(79 * DefaultStyle.dp)
        color: mainItem.enabled ? mainItem.backgroundColor : mainItem.disabledBackgroundColor
        border.color: mainItem.isError ? DefaultStyle.danger_500main : mainItem.activeFocus ? DefaultStyle.main1_500_main : mainItem.backgroundBorderColor
    }

    cursorDelegate: Rectangle {
        id: cursor
        color: DefaultStyle.main1_500_main
        width: Math.max(Math.round(1 * DefaultStyle.dp), 1)
        anchors.verticalCenter: mainItem.verticalCenter

        SequentialAnimation {
            loops: Animation.Infinite
            running: mainItem.cursorVisible

            PropertyAction {
                target: cursor
                property: 'visible'
                value: true
            }

            PauseAnimation {
                duration: 600
            }

            PropertyAction {
                target: cursor
                property: 'visible'
                value: false
            }

            PauseAnimation {
                duration: 600
            }

            onStopped: {
                cursor.visible = false
            }
        }
    }
    Keys.onPressed: event => {
        if (event.key == Qt.Key_Control)
        mainItem.controlIsDown = true
        if (event.key === Qt.Key_Enter
            || event.key === Qt.Key_Return) {
            enterPressed()
            if (mainItem.controlIsDown) {

            }
        }
    }
    Keys.onReleased: event => {
        if (event.jey == Qt.Key_Control)
        mainItem.controlIsDown = false
    }

    Button {
        id: eyeButton
        KeyNavigation.left: mainItem
        property real rightMargin: Math.round(15 * DefaultStyle.dp)
        z: 1
        visible: mainItem.hidden
        checkable: true
        style: ButtonStyle.noBackground
        icon.source: eyeButton.checked ? AppIcons.eyeShow : AppIcons.eyeHide
        width: Math.round(20 * DefaultStyle.dp)
        height: Math.round(20 * DefaultStyle.dp)
        icon.width: width
        icon.height: height
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: rightMargin
    }
}
