#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

#include "AccountSettingsModel.hpp"

// =============================================================================

class SettingsModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(bool autoAnswerStatus READ getAutoAnswerStatus WRITE setAutoAnswerStatus NOTIFY autoAnswerStatusChanged);

public:
  SettingsModel (QObject *parent = Q_NULLPTR);

signals:
  void autoAnswerStatusChanged (bool status);

private:
  bool getAutoAnswerStatus () const;
  bool setAutoAnswerStatus (bool status);

  std::shared_ptr<linphone::Config> m_config;

  static const std::string UI_SECTION;
};

#endif // SETTINGS_MODEL_H_
