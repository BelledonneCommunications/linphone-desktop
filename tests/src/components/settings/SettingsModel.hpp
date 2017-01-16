#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class SettingsModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(bool autoAnswerStatus READ getAutoAnswerStatus WRITE setAutoAnswerStatus NOTIFY autoAnswerStatusChanged);
  Q_PROPERTY(QString fileTransferUrl READ getFileTransferUrl WRITE setFileTransferUrl NOTIFY fileTransferUrlChanged);

public:
  SettingsModel (QObject *parent = Q_NULLPTR);

signals:
  void autoAnswerStatusChanged (bool status);
  void fileTransferUrlChanged (const QString &url);

private:
  bool getAutoAnswerStatus () const;
  void setAutoAnswerStatus (bool status);

  QString getFileTransferUrl () const;
  void setFileTransferUrl (const QString &url);

  std::shared_ptr<linphone::Config> m_config;

  static const std::string UI_SECTION;
};

#endif // SETTINGS_MODEL_H_
