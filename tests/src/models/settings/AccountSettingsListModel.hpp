#ifndef ACCOUNT_SETTINGS_LIST_MODEL_H_
#define ACCOUNT_SETTINGS_LIST_MODEL_H_

#include <QObject>

// ===================================================================

class AccountSettingsListModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(int index
             READ getDefaultAccount
             WRITE setDefaultAccount);

public:
  AccountSettingsListModel (QObject *parent = Q_NULLPTR);

private:
  int getDefaultAccount () const;
  void setDefaultAccount (int index);
};

#endif
