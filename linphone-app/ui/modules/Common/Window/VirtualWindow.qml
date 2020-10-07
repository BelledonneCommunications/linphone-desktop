import QtQuick 2.7
import QtQuick.Controls 2.5

import Common 1.0
import Common.Styles 1.0
import 'Window.js' as Logic

// =============================================================================
StackView{
    id:stackView
    anchors.fill: parent
    property var active : !stackView.empty
    visible:!stackView.empty
    
    function setContent(url, properties, exitStatusHandler){
        var isEmpty = stackView.empty;
        if(properties && properties.virtualWindowHash){
            var haveItem = stackView.find(function(item, index) {
                return item.sourceProperties && item.sourceProperties.virtualWindowHash && item.sourceProperties.virtualWindowHash == properties.virtualWindowHash;
            });
            if( haveItem == null ){//Push new
                push(page, {"sourceUrl":url, "sourceProperties":properties, "exitStatusHandler":exitStatusHandler, "setData":true, "active":true});
            }else{//Update fields
                haveItem.sourceProperties = properties;
                haveItem.exitStatusHandler = exitStatusHandler;
            }
        }else{
            push(page, {"sourceUrl":url, "sourceProperties":properties, "exitStatusHandler":exitStatusHandler, "setData":true, "active":true});
        }
        return isEmpty;
    }
    function unsetContent () {
        if(stackView.depth == 1)
            clear();
        else
            pop();
        return stackView.empty;
    }
    Component{
        id:page
        Loader {
            id:mainLoader
                active:false
                property var sourceUrl
                property var sourceProperties
                property var  exitStatusHandler
                property bool setData : false       // USe this flag to update source data

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
                            cursorShape: Qt.ArrowCursor
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
                            onLoaded:{// When loaded, attach handlers to content
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
    }
}
