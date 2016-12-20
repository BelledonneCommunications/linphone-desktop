#include "../sip-addresses/SipAddressesModel.hpp"

#include "TimelineModel.hpp"

// =============================================================================

TimelineModel::TimelineModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(SipAddressesModel::getInstance());
  sort(0);
}

QHash<int, QByteArray> TimelineModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$timelineEntry";
  return roles;
}

// -----------------------------------------------------------------------------

bool TimelineModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  return index.data().toMap().contains("timestamp");
}

bool TimelineModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const QVariantMap &sip_address_a = sourceModel()->data(left).toMap();
  const QVariantMap &sip_address_b = sourceModel()->data(right).toMap();

  return sip_address_a["timestamp"] > sip_address_b["timestamp"];
}
