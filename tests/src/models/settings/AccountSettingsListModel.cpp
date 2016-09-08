#include "AccountSettingsListModel.hpp"

// ===================================================================

AccountSettingsListModel::AccountSettingsListModel (QObject *parent) :
  QObject(parent) {
}

int AccountSettingsListModel::getDefaultAccount () const {
  return 1;
}

void AccountSettingsListModel::setDefaultAccount (int index) {
  // NOTHING TODO.
  (void)index;
}
