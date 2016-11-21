#ifndef TIMELINE_MODEL_H_
#define TIMELINE_MODEL_H_

#include <QAbstractListModel>

// ===================================================================

class TimelineModel : public QAbstractListModel {
  Q_OBJECT;

public:
  TimelineModel (QObject *parent = Q_NULLPTR);

  int rowCount (const QModelIndex &) const;
  QHash<int, QByteArray> roleNames () const;
  QVariant data (const QModelIndex &index, int role) const;

private:
  // A timeline enty is a object that contains:
  // - A QDateTime `timestamp`.
  // - A `sipAddresses` value, if it exists only one address, it's
  //   a string, otherwise it's a string array.
  QList<QVariantMap> m_entries;
};

#endif // TIMELINE_MODEL_H_
