#include "../core/CoreManager.hpp"

#include "UnregisteredSipAddressesProxyModel.hpp"

#define WEIGHT_POS_0 5
#define WEIGHT_POS_1 4
#define WEIGHT_POS_2 3
#define WEIGHT_POS_3 2
#define WEIGHT_POS_OTHER 1

// =============================================================================

const QRegExp UnregisteredSipAddressesProxyModel::m_search_separators("^[^_.-;@ ][_.-;@ ]");

// -----------------------------------------------------------------------------

UnregisteredSipAddressesProxyModel::UnregisteredSipAddressesProxyModel (QObject *parent) :
  QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getUnregisteredSipAddressesModel());
  setDynamicSortFilter(false);
  sort(0);
}

bool UnregisteredSipAddressesProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  return computeStringWeight(index.data().toMap()["sipAddress"].toString()) > 0;
}

bool UnregisteredSipAddressesProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  return computeStringWeight(
    sourceModel()->data(left).toMap()["sipAddress"].toString()
  ) > computeStringWeight(
    sourceModel()->data(right).toMap()["sipAddress"].toString()
  );
}

int UnregisteredSipAddressesProxyModel::computeStringWeight (const QString &string) const {
  int index = -1;
  int offset = -1;

  while ((index = filterRegExp().indexIn(string, index + 1)) != -1) {
    int tmp_offset = index - string.lastIndexOf(m_search_separators, index) - 1;
    if ((tmp_offset != -1 && tmp_offset < offset) || offset == -1)
      if ((offset = tmp_offset) == 0) break;
  }

  switch (offset) {
    case -1: return 0;
    case 0: return WEIGHT_POS_0;
    case 1: return WEIGHT_POS_1;
    case 2: return WEIGHT_POS_2;
    case 3: return WEIGHT_POS_3;
    default: break;
  }

  return WEIGHT_POS_OTHER;
}
