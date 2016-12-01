#ifndef TIMELINE_MODEL_H_
#define TIMELINE_MODEL_H_

#include <QAbstractListModel>

class ContactsListModel;

// ===================================================================

class TimelineModel : public QAbstractListModel {
  Q_OBJECT;

public:
  TimelineModel (const ContactsListModel *contacts_list);

  int rowCount (const QModelIndex &) const override;
  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

private:
  void init_entries ();

  // A timeline enty is a object that contains:
  // - A QDateTime `timestamp`.
  // - A `sipAddresses` value, if it exists only one address, it's
  //   a string, otherwise it's a string array.
  QList<QVariantMap> m_entries;
};

#endif // TIMELINE_MODEL_H_
