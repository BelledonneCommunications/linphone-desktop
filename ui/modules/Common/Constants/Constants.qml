pragma Singleton
import QtQuick 2.7

// =============================================================================

QtObject {
  property int zPopup: 999
  property int zMax: 999999
  property int sizeMax: 999999

  property string imagesFormat: '.svg'
  // property string imagesPath: 'image://internal/'
  property string imagesPath: 'qrc:/assets/images/'
}
