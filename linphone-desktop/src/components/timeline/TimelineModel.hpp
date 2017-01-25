#ifndef TIMELINE_MODEL_H_
#define TIMELINE_MODEL_H_

#include <QSortFilterProxyModel>

// =============================================================================

class TimelineModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  TimelineModel (QObject *parent = Q_NULLPTR);
  ~TimelineModel () = default;

  QHash<int, QByteArray> roleNames () const override;

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
};

#endif // TIMELINE_MODEL_H_
