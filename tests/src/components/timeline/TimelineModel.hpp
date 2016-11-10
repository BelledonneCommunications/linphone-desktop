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
  QStringList m_addresses;
};

#endif // TIMELINE_MODEL_H_
