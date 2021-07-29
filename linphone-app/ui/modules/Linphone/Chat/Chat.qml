import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0

import 'Chat.js' as Logic

// =============================================================================

Rectangle {
  id: container

  property alias proxyModel: chat.model	// ChatRoomProxyModel

  // ---------------------------------------------------------------------------

  signal messageToSend (string text)

  // ---------------------------------------------------------------------------

  color: ChatStyle.color

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    ScrollableListView {
      id: chat

      // -----------------------------------------------------------------------

      property bool bindToEnd: false
      property bool tryToLoadMoreEntries: true
      //property var sipAddressObserver: SipAddressesModel.getSipAddressObserver(proxyModel.fullPeerAddress, proxyModel.fullLocalAddress)

      // -----------------------------------------------------------------------

      Layout.fillHeight: true
      Layout.fillWidth: true

      highlightFollowsCurrentItem: false

      section {
        criteria: ViewSection.FullString
        delegate: sectionHeading
        property: '$sectionDate'
      }

      // -----------------------------------------------------------------------

      Component.onCompleted: Logic.initView()

      onContentYChanged: Logic.loadMoreEntries()
      onMovementEnded: Logic.handleMovementEnded()
      onMovementStarted: Logic.handleMovementStarted()

      // -----------------------------------------------------------------------

      Connections {
        target: proxyModel

        // When the view is changed (for example `Calls` -> `Messages`),
        // the position is set at end and it can be possible to load
        // more entries.
        onEntryTypeFilterChanged: Logic.initView()
        onMoreEntriesLoaded: Logic.handleMoreEntriesLoaded(n)
      }

      // -----------------------------------------------------------------------
      // Heading.
      // -----------------------------------------------------------------------

      Component {
        id: sectionHeading

        Item {
          implicitHeight: container.height + ChatStyle.sectionHeading.bottomMargin
          width: parent.width

          Borders {
            id: container

            borderColor: ChatStyle.sectionHeading.border.color
            bottomWidth: ChatStyle.sectionHeading.border.width
            implicitHeight: text.contentHeight +
              ChatStyle.sectionHeading.padding * 2 +
              ChatStyle.sectionHeading.border.width * 2
            topWidth: ChatStyle.sectionHeading.border.width
            width: parent.width

            Text {
              id: text

              anchors.fill: parent
              //color: ChatStyle.sectionHeading.text.color
              color: '#979797'
              font {
                bold: true
                pointSize: ChatStyle.sectionHeading.text.pointSize
              }
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter

              // Cast section to integer because Qt converts the
              // sectionDate in string!!!
              text: new Date(section).toLocaleDateString(
                Qt.locale(App.locale)
              )
            }
          }
        }
      }

      // -----------------------------------------------------------------------
      // Message/Event renderer.
      // -----------------------------------------------------------------------

      delegate: Rectangle {
        id: entry
		property bool isNotice : $chatEntry.type === ChatRoomModel.NoticeEntry

        function isHoverEntry () {
          return mouseArea.containsMouse
        }

        function removeEntry () {
          proxyModel.removeRow(index)
        }

        anchors {
          left: parent ? parent.left : undefined
		  leftMargin: isNotice?0:ChatStyle.entry.leftMargin
          right: parent ? parent.right : undefined

		  rightMargin: isNotice?0:ChatStyle.entry.deleteIconSize +
            ChatStyle.entry.message.extraContent.spacing +
            ChatStyle.entry.message.extraContent.rightMargin +
            ChatStyle.entry.message.extraContent.leftMargin +
            ChatStyle.entry.message.outgoing.areaSize
        }

        color: ChatStyle.color
        implicitHeight: layout.height + ChatStyle.entry.bottomMargin

        // ---------------------------------------------------------------------

        MouseArea {
          id: mouseArea

          cursorShape: Qt.ArrowCursor
          hoverEnabled: true
          implicitHeight: layout.height
          width: parent.width + parent.anchors.rightMargin

          RowLayout {
            id: layout

            spacing: 0
            width: entry.width

            // Display time.
            Text {
              Layout.alignment: Qt.AlignTop
              Layout.preferredHeight: ChatStyle.entry.lineHeight
              Layout.preferredWidth: ChatStyle.entry.time.width

              color: '#B1B1B1'
              font.pointSize: ChatStyle.entry.time.pointSize

              text: $chatEntry.timestamp.toLocaleString(
                Qt.locale(App.locale),
                'hh:mm'
              )

              verticalAlignment: Text.AlignVCenter

              TooltipArea {
                text: $chatEntry.timestamp.toLocaleString(Qt.locale(App.locale))
              }
			  visible:!isNotice
            }

            // Display content.
            Loader {
              Layout.fillWidth: true
              source: Logic.getComponentFromEntry($chatEntry)
            }
          }
        }
      }

      footer: Text {
					property var composers : container.proxyModel.composers
					color: ChatStyle.composingText.color
					font.pointSize: ChatStyle.composingText.pointSize
					height: visible ? undefined : 0
					leftPadding: ChatStyle.composingText.leftPadding
					visible: composers.length > 0 && SettingsModel.chatEnabled
					wrapMode: Text.Wrap

					text:(composers.length==0?'':(composers.length>1 ? '%1 are typing...' : '%1 is typing...').arg(container.proxyModel.getDisplayNameComposers()))
				}
      
      
      /* GridView{
			height: visible ? ChatStyle.composingText.height*container.proxyModel.composers.length : 0
			width:parent.width
			cellWidth: parent.width; cellHeight: ChatStyle.composingText.height
			
			property var composersLength : container.proxyModel.composers.length
			onComposersLengthChanged:{
				model.clear()
				console.log(container.proxyModel.composers)
				for(var j  = 0 ; j < container.proxyModel.composers.length ; ++j) {
					console.log(container.proxyModel.composers[j])
					model.append({text:container.proxyModel.composers[j]})
				}
			}
			model: ListModel{}
			delegate:Rectangle{
			height:ChatStyle.composingText.height
			width:parent.width
			color:"red"
			}
      }*/
      
      
      /*
       Column{
			height: 100 *container.proxyModel.composers.length
			width:parent.width
			onHeightChanged: {
				composerRepeater.model = []
				composerRepeater.model = container.proxyModel.composers
			}
		Repeater{
		id:composerRepeater
			model:["toto"]
			Rectangle{
			height:100
			width:parent.width
			color:"red"
			}
		}
      }*/
      
      
      /*
      Column{
			height: visible ? ChatStyle.composingText.height*container.proxyModel.composers.length : 0
			width:parent.width
			visible:SettingsModel.chatEnabled
			onHeightChanged: {
				composers.clear()
				composerRepeater.model = []
				composerRepeater.model = container.proxyModel.composers
			}
			Repeater{
				id:composerRepeater
				model:ListModel{
					id:composers
				}
				onModelChanged: console.log(container.proxyModel.composers.length)
				
				Text {
					color: ChatStyle.composingText.color
					font.pointSize: ChatStyle.composingText.pointSize
					height: visible ? ChatStyle.composingText.height : 0
					
					leftPadding: ChatStyle.composingText.leftPadding
					visible: text.length > 0 && SettingsModel.chatEnabled
	
					text: modelData + ' ' +'is typing...'
					Component.onCompleted: console.log(text + "=>" +width+"/"+height+" : "+visible)
				}
			}
		  }*/
    }

    // -------------------------------------------------------------------------
    // Send area.
    // -------------------------------------------------------------------------

    Borders {
      Layout.fillWidth: true
      Layout.preferredHeight: textArea.height

      borderColor: ChatStyle.sendArea.border.color
      topWidth: ChatStyle.sendArea.border.width
      visible: SettingsModel.chatEnabled

      DroppableTextArea {
        id: textArea
		
		enabled:proxyModel && proxyModel.chatRoomModel ? !proxyModel.chatRoomModel.hasBeenLeft:false
		isEphemeral : proxyModel && proxyModel.chatRoomModel ? proxyModel.chatRoomModel.ephemeralEnabled:false

        anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		
		height:ChatStyle.sendArea.height + ChatStyle.sendArea.border.width
		minimumHeight:ChatStyle.sendArea.height + ChatStyle.sendArea.border.width
		maximumHeight:container.height/2

        dropEnabled: SettingsModel.fileTransferUrl.length > 0
        dropDisabledReason: qsTr('noFileTransferUrl')
        placeholderText: qsTr('newMessagePlaceholder')

        onDropped: Logic.handleFilesDropped(files)
        onTextChanged: Logic.handleTextChanged(text)
		onValidText: {
			textArea.text = ''
			chat.bindToEnd = true
			if(proxyModel.chatRoomModel)
				proxyModel.sendMessage(text)
			else{
				console.log("Peer : " +proxyModel.peerAddress+ "/"+chat.model.peerAddress)
				proxyModel.chatRoomModel = CallsListModel.createChat(proxyModel.peerAddress)
				proxyModel.sendMessage(text)
			}
		}
        Component.onCompleted: {text = proxyModel.cachedText; cursorPosition=text.length}
		Rectangle{
			anchors.fill:parent
			color:'white'
			opacity: 0.5
			visible:!textArea.enabled
		}
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Scroll at end if necessary.
  // ---------------------------------------------------------------------------

  Timer {
    interval: 100
    repeat: true
    running: true

    onTriggered: chat.bindToEnd && chat.positionViewAtEnd()
  }
}
