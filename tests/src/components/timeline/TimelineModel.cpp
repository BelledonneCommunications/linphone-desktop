#include "../core/CoreManager.hpp"

#include "TimelineModel.hpp"

// =============================================================================

TimelineModel::TimelineModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getSipAddressesModel());
  sort(0);
}

QHash<int, QByteArray> TimelineModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$timelineEntry";
  return roles;
}

// -----------------------------------------------------------------------------

bool TimelineModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  const QModelIndex &index = sourceModel()->index(source_row, 0, source_parent);
  const QVariantMap &map = index.data().toMap();

  return map.contains("timestamp");
}

bool TimelineModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const QVariantMap &sip_address_a = sourceModel()->data(left).toMap();
  const QVariantMap &sip_address_b = sourceModel()->data(right).toMap();

  return sip_address_a["timestamp"] > sip_address_b["timestamp"];
}
