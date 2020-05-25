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
    property bool setData : false       // USe this flag to update source data
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

        Item{
            id:rootContent
            property alias contentLoader:content.contentLoader
            anchors.fill: parent
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onWheel: wheel.accepted = true
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
                    onSetSourceDataChanged: if( setData) {// SetData is true : assign source with properties using QML functions
                                                if(sourceProperties)
                                                    setSource(sourceUrl, sourceProperties);
                                                else
                                                    setSource(sourceUrl);
                                            }else{source=undefined}// SetData is false : clean memory
                    active:mainLoader.active
                    onLoaded:{// When loaded, attache handlers to content
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
