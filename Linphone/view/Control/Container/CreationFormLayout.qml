import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import QtQuick.Effects

import Linphone
import UtilsCpp
import SettingsCpp

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
    property int searchBarRightMaring: Math.round(39 * DefaultStyle.dp)

	ColumnLayout {
		anchors.fill: parent
        spacing: Math.round(22 * DefaultStyle.dp)
		ColumnLayout {
            id: topLayout
            visible: mainItem.topLayoutVisible
            spacing: Math.round(18 * DefaultStyle.dp)
		}

        ColumnLayout {
            onVisibleChanged: if (!visible && mainItem.numPadPopup) mainItem.numPadPopup.close()
            spacing: Math.round(38 * DefaultStyle.dp)
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
                KeyNavigation.down: grouCreationButton
            }
            ColumnLayout {
                id: content
                spacing: Math.round(32 * DefaultStyle.dp)
                Button {
                    id: grouCreationButton
                    Layout.preferredWidth: Math.round(320 * DefaultStyle.dp)
                    Layout.preferredHeight: Math.round(44 * DefaultStyle.dp)
                    padding: 0
                    KeyNavigation.up: searchBar
                    KeyNavigation.down: contactList
                    onClicked: mainItem.groupCreationRequested()
                    background: Rectangle {
                        anchors.fill: parent
                        radius: Math.round(50 * DefaultStyle.dp)
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: DefaultStyle.main2_100}
                            GradientStop { position: 1.0; color: DefaultStyle.grey_0}
                        }
                    }
                    contentItem: RowLayout {
                        spacing: Math.round(16 * DefaultStyle.dp)
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            source: AppIcons.groupCall
                            Layout.preferredWidth: Math.round(44 * DefaultStyle.dp)
                            sourceSize.width: Math.round(44 * DefaultStyle.dp)
                            fillMode: Image.PreserveAspectFit
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
                            Layout.preferredWidth: Math.round(24 * DefaultStyle.dp)
                            Layout.preferredHeight: Math.round(24 * DefaultStyle.dp)
                            colorizationColor: DefaultStyle.main2_500main
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
