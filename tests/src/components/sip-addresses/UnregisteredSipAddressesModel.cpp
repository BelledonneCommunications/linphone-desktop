#include "../core/CoreManager.hpp"

#include "UnregisteredSipAddressesModel.hpp"

// =============================================================================

UnregisteredSipAddressesModel::UnregisteredSipAddressesModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getSipAddressesModel());
}

bool UnregisteredSipAddressesModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  return index.data().toMap().contains("contact");
}
