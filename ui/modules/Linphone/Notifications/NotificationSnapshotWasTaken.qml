import Utils 1.0

// =============================================================================

NotificationBasic {
  icon: 'snapshot_sign'
  message: notificationData.filePath
  handler: (function () {
    Qt.openUrlExternally(Utils.dirname(
      Utils.getUriFromSystemPath(notificationData.filePath)
    ))
  })
}
