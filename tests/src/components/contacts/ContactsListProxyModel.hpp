#ifndef CONTACTS_LIST_PROXY_MODEL_H
#define CONTACTS_LIST_PROXY_MODEL_H

#include <QSortFilterProxyModel>

#include "ContactsListModel.hpp"

// ===================================================================

class ContactsListProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  ContactsListProxyModel (QObject *parent = Q_NULLPTR);
  static void initContactsListModel (ContactsListModel *list);

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const;
  bool lessThan(const QModelIndex &left, const QModelIndex &right) const;

private:
  static ContactsListModel *m_list;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H
