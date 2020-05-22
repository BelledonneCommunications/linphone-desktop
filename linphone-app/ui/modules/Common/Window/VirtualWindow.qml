import QtQuick 2.7

import Common.Styles 1.0
import 'Window.js' as Logic

// =============================================================================

Loader {
    id:mainLoader
    active:false
    property var sourceUrl
    property var sourceProperties
    property var  exitStatusHandler
    property bool setData : false
    anchors.fill: parent

  function setContent (url, properties, exitStatusHandler) {

    mainLoader.sourceUrl=url;
    mainLoader.sourceProperties=properties;
    mainLoader.exitStatusHandler=exitStatusHandler;
    setData=true;
    active=true;
  }

  function unsetContent () {
    active=false
    setData=false;
  }

  // ---------------------------------------------------------------------------
  sourceComponent:Component{
    id:mainComponent
    //property alias contentLoader:rootContent.contentLoader
 // visible: false onIsLoadedChanged: console.log("Loaded:"+isLoaded)

    Item{
        id:rootContent
        property alias contentLoader:content.contentLoader
        anchors.fill: parent
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onWheel: wheel.accepted = true
          onClicked:console.log("clicked")
        }

        Rectangle {
          id: content
          property alias contentLoader:contentLoader

         anchors.fill: parent
         color: WindowStyle.transientWindow.color
         Loader{
            id:contentLoader
            anchors.centerIn: parent
            property var setSourceData : setData
            onSetSourceDataChanged: if( setData) {console.log(sourceUrl+" "+sourceProperties);
            if(sourceProperties)
                setSource(sourceUrl, sourceProperties);
                else
                setSource(sourceUrl);

                 }else{source=undefined}
            active:mainLoader.active
            onLoaded:{
                        item.exitStatus.connect(Logic.detachVirtualWindow)
                        if (exitStatusHandler) {
                                item.exitStatus.connect(exitStatusHandler)
                        }
            }
         }
        }
     }
  }
}
