NotificationBasic {
  icon: 'update_sign'
  message: notificationData.message?notificationData.message:''
  handler: (function () {
    Qt.openUrlExternally(notificationData.url)
  })
}
