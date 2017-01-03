#include <QDateTime>

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
  return index.data().toMap().contains("timestamp");
}

bool TimelineModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  return sourceModel()->data(left).toMap()["timestamp"].toDateTime().toMSecsSinceEpoch() >
         sourceModel()->data(right).toMap()["timestamp"].toDateTime().toMSecsSinceEpoch();
}
