import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

FocusScope {
	id: mainItem
	property color searchBarColor: DefaultStyle.grey_100
	property color searchBarBorderColor: "transparent"
	property alias searchBar: searchBar
    property string startGroupButtonText
	property NumericPadPopup numPadPopup
	signal groupCreationRequested()
	signal contactClicked(FriendGui contact)
	clip: true
    property alias topContent: topLayout.data
    property bool topLayoutVisible: topLayout.children.length > 0
    property int searchBarRightMaring: Utils.getSizeWithScreenRatio(39)

	ColumnLayout {
		anchors.fill: parent
        spacing: Utils.getSizeWithScreenRatio(22)
		ColumnLayout {
            id: topLayout
            visible: mainItem.topLayoutVisible
            spacing: Utils.getSizeWithScreenRatio(18)
		}

        ColumnLayout {
            onVisibleChanged: if (!visible && mainItem.numPadPopup) mainItem.numPadPopup.close()
            spacing: Utils.getSizeWithScreenRatio(38)
            SearchBar {
                id: searchBar
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: true
                Layout.rightMargin: mainItem.searchBarRightMaring
                focus: true
                color: mainItem.searchBarColor
                borderColor: mainItem.searchBarBorderColor
                //: "Rechercher un contact"
                placeholderText: qsTr("search_bar_look_for_contact_text")
                numericPadPopup: mainItem.numPadPopup
                KeyNavigation.down: groupCreationButton
            }
            ColumnLayout {
                id: content
                spacing: Utils.getSizeWithScreenRatio(32)
                Button {
                    id: groupCreationButton
                    Layout.preferredWidth: Utils.getSizeWithScreenRatio(320)
                    Layout.preferredHeight: Utils.getSizeWithScreenRatio(44)
                    padding: 0
                    KeyNavigation.up: searchBar
                    KeyNavigation.down: contactList
                    onClicked: mainItem.groupCreationRequested()
                    background: Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: DefaultStyle.main2_100}
                            GradientStop { position: 1.0; color: DefaultStyle.grey_0}
                        }
                        // Black border for keyboard navigation
                        border.color: DefaultStyle.main2_900
                        border.width: groupCreationButton.keyboardFocus ? Utils.getSizeWithScreenRatio(3) : 0
                    }
                    Accessible.name: mainItem.startGroupButtonText
                    contentItem: RowLayout {
                        spacing: Math.round(16 * DefaultStyle.dp)
                        anchors.verticalCenter: parent.verticalCenter
                        Rectangle {
                            width: Math.round(44 * DefaultStyle.dp)
                            height: width
                            radius: width / 2
                            color: DefaultStyle.main1_500_main
                            EffectImage {
                                imageSource: AppIcons.usersThreeFilled
                                anchors.centerIn: parent
                                width: Math.round(24 * DefaultStyle.dp)
                                height: width
                                fillMode: Image.PreserveAspectFit
                                colorizationColor: DefaultStyle.grey_0
                            }
                        }
                        Text {
                            text: mainItem.startGroupButtonText
                            color: DefaultStyle.grey_1000
                            font {
                                pixelSize: Typography.h4.pixelSize
                                weight: Typography.h4.weight
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        EffectImage {
                            imageSource: AppIcons.rightArrow
                            Layout.preferredWidth: Utils.getSizeWithScreenRatio(24)
                            Layout.preferredHeight: Utils.getSizeWithScreenRatio(24)
                            colorizationColor: DefaultStyle.main2_500_main
                        }
                    }
                }
                AllContactListView{
                    id: contactList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    showContactMenu: false
                    searchBarText: searchBar.text
                    onContactSelected: (contact) => {
                        mainItem.contactClicked(contact)
                    }
                }
            }
        }
    }
}
