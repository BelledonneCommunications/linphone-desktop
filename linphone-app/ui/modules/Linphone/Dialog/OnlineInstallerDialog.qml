import QtQuick 2.7
import QtQuick.Controls 2.2

import Common 1.0
import Linphone 1.0
import Linphone.Styles 1.0
import Utils 1.0

// =============================================================================

DialogPlus {
  id: dialog

  // ---------------------------------------------------------------------------

  property alias downloadUrl: fileDownloader.url
  property alias installFolder: fileDownloader.downloadFolder
  property alias checksum: fileDownloader.checksum
  property string installName // Right install name.
  property string mime // Human readable name.

  property bool _installing: false
  property int _exitStatus: -1 // Not downloaded for the moment.

  // ---------------------------------------------------------------------------

  function install () {
    dialog._installing = true
    fileDownloader.download()
  }

  function _endInstall (exitStatus) {
    if (exitStatus === 1) {
      Utils.write(installFolder + mime + '.txt', downloadUrl)
    }
    dialog._exitStatus = exitStatus
    dialog._installing = false
  }

  // ---------------------------------------------------------------------------

  // TODO: Improve one day. Do not launch download directly.
  // Provide a download function (window.attachVirtualWindow cannot call
  // function after creation at this moment).
  Component.onCompleted: dialog.install()

  // ---------------------------------------------------------------------------

  buttons: [
    // TODO: Add a retry button???
    TextButtonB {
      enabled: !dialog._installing && !fileDownloader.downloading && !fileExtractor.extracting
      text: qsTr('confirm')

      onClicked: exit(1)
    }
  ]

  buttonsAlignment: Qt.AlignCenter
  descriptionText: {
    var str

    if (dialog.extracting) {
      str = qsTr('onlineInstallerExtractingDescription')
    } else if (dialog._installing) {
      str = qsTr('onlineInstallerDownloadingDescription')
    } else if (dialog._exitStatus > 0) {
      str = qsTr('onlineInstallerFinishedDescription')
    } else {
      str = qsTr('onlineInstallerFailedDescription')
    }

    return str.replace('%1', dialog.mime)
  }
  height: OnlineInstallerDialogStyle.height + 30
  width: OnlineInstallerDialogStyle.width

  Column {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    spacing: OnlineInstallerDialogStyle.column.spacing

    ProgressBar {
      id: progressBar

      property var target: fileDownloader

      height: OnlineInstallerDialogStyle.column.bar.height
      width: parent.width

      to: target.totalBytes
      value: target.readBytes
      indeterminate : target.totalBytes == 0

      background: Rectangle {
        color: OnlineInstallerDialogStyle.column.bar.background.colorModel.color
        radius: OnlineInstallerDialogStyle.column.bar.radius
      }

      contentItem: Item {
        Rectangle {
          color: dialog._exitStatus
            ? OnlineInstallerDialogStyle.column.bar.contentItem.color.normal.color
            : OnlineInstallerDialogStyle.column.bar.contentItem.color.failed.color
          height: parent.height
          radius: OnlineInstallerDialogStyle.column.bar.radius
          width: progressBar.visualPosition * parent.width
        }
      }
    }

    Text {
      anchors.right: parent.right
      color: OnlineInstallerDialogStyle.column.text.colorModel.color
      font.pointSize: OnlineInstallerDialogStyle.column.text.pointSize

      text: {
        var target = progressBar.target
        var fileSize = Utils.formatSize(target.totalBytes)
        return Utils.formatSize(target.readBytes) + '/' + fileSize
      }
    }

    FileDownloader {
      id: fileDownloader

      onDownloadFailed: dialog._endInstall(0)
      onDownloadFinished: {
        fileExtractor.file = filePath
        progressBar.target = fileExtractor
        fileExtractor.extract()
      }
    }

    FileExtractor {
      id: fileExtractor

      extractFolder: dialog.installFolder
      extractName: dialog.installName

      onExtractFailed: {fileDownloader.remove(); dialog._endInstall(0)}
      onExtractFinished: {fileDownloader.remove(); dialog._endInstall(1)}
    }
  }
}
