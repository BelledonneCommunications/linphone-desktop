NotificationBasic {
  icon: 'update_sign'
  message: notificationData.url
  handler: (function () {
    Qt.openUrlExternally(notificationData.url)
  })
}
