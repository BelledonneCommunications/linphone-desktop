#ifndef SETTINGS_MODEL_H_
#define SETTINGS_MODEL_H_

#include <QObject>

#include "AccountSettingsModel.hpp"

// ===================================================================

class SettingsModel : public QObject {
  Q_OBJECT;

public:
  SettingsModel (QObject *parent = Q_NULLPTR);

private:
  QList<AccountSettingsModel *> accountsSettings;
};

#endif // SETTINGS_MODEL_H_
