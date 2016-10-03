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
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const;

private:
  float computeContactWeight (const ContactModel &contact) const;

  // The contacts list is shared between `ContactsListProxyModel`
  // it's necessary to initialize it with `initContactsListModel`.
  static ContactsListModel *m_list;

  // It's just a cache to save values computed by `filterAcceptsRow`
  // and reused by `lessThan`.
  mutable QHash<const ContactModel *, float> m_weights;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H
