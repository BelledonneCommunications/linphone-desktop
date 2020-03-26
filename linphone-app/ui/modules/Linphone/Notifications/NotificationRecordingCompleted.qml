import Utils 1.0

// =============================================================================

NotificationBasic {
  icon: 'recording_sign'
  message: Utils.basename(notificationData.filePath)
  handler: (function () {
    Qt.openUrlExternally(Utils.dirname(
      Utils.getUriFromSystemPath(notificationData.filePath)
    ))
  })
}
