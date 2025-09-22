import QtQuick
import QtQuick.Controls.Basic as Control
import QtQuick.Layouts
import QtQuick.Effects
import Linphone
import CustomControls 1.0
import "qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js" as Utils

Control.ComboBox {
    id: mainItem
    // Usage : each item of the model list must be {text: …, img: …}
    // If string list, only text part of the delegate will be filled
    // readonly property string currentText: selectedItemText.text
    property alias listView: listView
    property string constantImageSource
    property real pixelSize: Typography.p1.pixelSize
    property real weight: Typography.p1.weight
    property real leftMargin: Utils.getSizeWithScreenRatio(10)
    property bool oneLine: false
    property bool shadowEnabled: mainItem.activeFocus || mainItem.hovered
    property string flagRole // Specific case if flag is shown (special font)
    property var indicatorColor: DefaultStyle.main2_600
    property int indicatorRightMargin: Utils.getSizeWithScreenRatio(20)
    leftPadding: Utils.getSizeWithScreenRatio(10)
    rightPadding: indicImage.width + indicatorRightMargin
    property bool keyboardFocus: FocusHelper.keyboardFocus
    // Text properties
    property color textColor: DefaultStyle.main2_600
    property color disabledTextColor: DefaultStyle.grey_400
    // Border properties
    property color borderColor: DefaultStyle.grey_200
    property color disabledBorderColor: DefaultStyle.grey_400
    property color activeFocusedBorderColor: DefaultStyle.main1_500_main
    property color keyboardFocusedBorderColor: DefaultStyle.main2_900
    property real borderWidth: Utils.getSizeWithScreenRatio(1)
    property real keyboardFocusedBorderWidth: Utils.getSizeWithScreenRatio(3)
    // Background properties
    property color color: DefaultStyle.grey_100
    property color disabledColor: DefaultStyle.grey_200

    onConstantImageSourceChanged: if (constantImageSource)
        selectedItemImg.imageSource = constantImageSource
    onCurrentIndexChanged: {
        var item = model[currentIndex];
        if (!item)
            item = model.getAt(currentIndex);
        if (!item)
            return;
        selectedItemText.text = mainItem.textRole ? item[mainItem.textRole] : item.text ? item.text : item ? item : "";
        if (mainItem.flagRole)
            selectedItemFlag.text = item[mainItem.flagRole];
        selectedItemImg.imageSource = constantImageSource ? constantImageSource : item.img ? item.img : "";
    }

    Keys.onPressed: event => {
        if (!mainItem.contentItem.activeFocus && (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return)) {
            mainItem.popup.open();
            event.accepted = true;
        }
    }

    background: Item {
        Rectangle {
            id: buttonBackground
            anchors.fill: parent
            radius: Math.round(mainItem.height / 2)
            color: mainItem.enabled ? mainItem.color : mainItem.disabledColor
            border.color: !mainItem.enabled ? mainItem.disabledBorderColor : mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderColor : mainItem.activeFocus || mainItem.popup.opened ? mainItem.activeFocusedBorderColor : mainItem.borderColor
            border.width: mainItem.keyboardFocus ? mainItem.keyboardFocusedBorderWidth : mainItem.borderWidth
        }
        MultiEffect {
            enabled: mainItem.shadowEnabled
            anchors.fill: buttonBackground
            source: buttonBackground
            visible: mainItem.shadowEnabled
            // Crash : https://bugreports.qt.io/browse/QTBUG-124730
            shadowEnabled: true //mainItem.shadowEnabled
            shadowColor: DefaultStyle.grey_1000
            shadowBlur: 0.5
            shadowOpacity: mainItem.shadowEnabled ? 0.1 : 0.0
        }
    }
    contentItem: RowLayout {
        spacing: Utils.getSizeWithScreenRatio(5)
        EffectImage {
            id: selectedItemImg
            Layout.preferredWidth: visible ? Utils.getSizeWithScreenRatio(24) : 0
            Layout.preferredHeight: visible ? Utils.getSizeWithScreenRatio(24) : 0
            Layout.leftMargin: mainItem.leftMargin
            imageSource: mainItem.constantImageSource ? mainItem.constantImageSource : ""
            colorizationColor: mainItem.enabled ? mainItem.textColor : mainItem.disabledTextColor
            visible: imageSource != ""
            fillMode: Image.PreserveAspectFit
        }
        Text {
            id: selectedItemFlag
            Layout.preferredWidth: implicitWidth
            Layout.leftMargin: selectedItemImg.visible ? 0 : Utils.getSizeWithScreenRatio(5)
            Layout.alignment: Qt.AlignCenter
            color: mainItem.enabled ? mainItem.textColor : mainItem.disabledTextColor
            font {
                family: DefaultStyle.flagFont
                pixelSize: mainItem.pixelSize
                weight: mainItem.weight
            }
        }
        Text {
            id: selectedItemText
            Layout.fillWidth: true
            Layout.leftMargin: selectedItemImg.visible ? 0 : Utils.getSizeWithScreenRatio(5)
            Layout.rightMargin: Utils.getSizeWithScreenRatio(20)
            Layout.alignment: Qt.AlignCenter
            color: mainItem.enabled ? mainItem.textColor : mainItem.disabledTextColor
            elide: Text.ElideRight
            maximumLineCount: oneLine ? 1 : 2
            wrapMode: Text.WrapAnywhere
            font {
                family: DefaultStyle.defaultFont
                pixelSize: mainItem.pixelSize
                weight: mainItem.weight
            }
        }
    }

    indicator: EffectImage {
        id: indicImage
        z: 1
        anchors.right: parent.right
        anchors.rightMargin: mainItem.indicatorRightMargin
        anchors.verticalCenter: parent.verticalCenter
        imageSource: AppIcons.downArrow
        width: Utils.getSizeWithScreenRatio(15)
        height: Utils.getSizeWithScreenRatio(15)
        fillMode: Image.PreserveAspectFit
        colorizationColor: mainItem.indicatorColor
        // Rotate when popup open/close
        transformOrigin: Item.Center
        rotation: mainItem.popup.opened ? 180 : 0
        Behavior on rotation {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    popup: Control.Popup {
        id: popup
        y: mainItem.height - 1
        width: mainItem.width
        implicitHeight: Math.min(contentItem.implicitHeight, mainWindow.height)
        padding: Math.max(Math.round(1 * DefaultStyle.dp), 1)

        onOpened: {
            listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
            listView.forceActiveFocus();
        }
        contentItem: ListView {
            id: listView
            clip: true
            implicitHeight: contentHeight
            height: popup.height
            model: visible ? mainItem.model : []
            currentIndex: mainItem.highlightedIndex >= 0 ? mainItem.highlightedIndex : 0
            highlightFollowsCurrentItem: true
            highlightMoveDuration: -1
            highlightMoveVelocity: -1
            highlight: Rectangle {
                width: listView.width
                color: DefaultStyle.main2_200
                radius: Math.round(15 * DefaultStyle.dp)
                y: listView.currentItem ? listView.currentItem.y : 0
            }

            Keys.onPressed: event => {
                if (event.key == Qt.Key_Space || event.key == Qt.Key_Enter || event.key == Qt.Key_Return) {
                    event.accepted = true;
                    mainItem.currentIndex = listView.currentIndex;
                    popup.close();
                }
            }

            delegate: Item {
                width: mainItem.width
                height: mainItem.height
                // anchors.left: listView.left
                // anchors.right: listView.right
                Accessible.name: typeof (modelData) != "undefined" ? mainItem.textRole ? modelData[mainItem.textRole] : modelData.text ? modelData.text : modelData : $modelData ? mainItem.textRole ? $modelData[mainItem.textRole] : $modelData : ""
                RowLayout {
                    anchors.fill: parent
                    EffectImage {
                        id: delegateImg
                        Layout.preferredWidth: visible ? Math.round(20 * DefaultStyle.dp) : 0
                        Layout.leftMargin: Math.round(10 * DefaultStyle.dp)
                        visible: imageSource != ""
                        imageWidth: Math.round(20 * DefaultStyle.dp)
                        imageSource: typeof (modelData) != "undefined" && modelData.img ? modelData.img : ""
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        id: flagItem
                        Layout.preferredWidth: implicitWidth
                        Layout.leftMargin: delegateImg.visible ? 0 : Math.round(5 * DefaultStyle.dp)
                        Layout.alignment: Qt.AlignCenter
                        visible: mainItem.flagRole
                        font {
                            family: DefaultStyle.flagFont
                            pixelSize: mainItem.pixelSize
                            weight: mainItem.weight
                        }
                        text: mainItem.flagRole ? typeof (modelData) != "undefined" ? modelData[mainItem.flagRole] : $modelData[mainItem.flagRole] : ""
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: delegateImg.visible ? 0 : flagItem.visble ? Utils.getSizeWithScreenRatio(5) : Utils.getSizeWithScreenRatio(25)
                        Layout.rightMargin: Math.round(20 * DefaultStyle.dp)
                        Layout.alignment: Qt.AlignCenter
                        text: typeof (modelData) != "undefined" ? mainItem.textRole ? modelData[mainItem.textRole] : modelData.text ? modelData.text : modelData : $modelData ? mainItem.textRole ? $modelData[mainItem.textRole] : $modelData : ""
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        wrapMode: Text.WrapAnywhere
                        font {
                            family: DefaultStyle.defaultFont
                            pixelSize: Utils.getSizeWithScreenRatio(15)
                            weight: Math.min(Utils.getSizeWithScreenRatio(400), 1000)
                        }
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    Rectangle {
                        anchors.fill: parent
                        opacity: 0.1
                        radius: Utils.getSizeWithScreenRatio(15)
                        color: DefaultStyle.main2_500_main
                        visible: parent.containsMouse
                    }
                    onClicked: {
                        mainItem.currentIndex = index;
                        popup.close();
                    }
                }
            }

            Control.ScrollIndicator.vertical: Control.ScrollIndicator {}
        }

        background: Item {
            implicitWidth: mainItem.width
            implicitHeight: Utils.getSizeWithScreenRatio(30)
            Rectangle {
                id: cboxBg
                anchors.fill: parent
                radius: Utils.getSizeWithScreenRatio(15)
            }
            MultiEffect {
                anchors.fill: cboxBg
                source: cboxBg
                shadowEnabled: true
                shadowColor: DefaultStyle.grey_1000
                shadowBlur: 0.1
                shadowOpacity: 0.1
            }
        }
    }
}
