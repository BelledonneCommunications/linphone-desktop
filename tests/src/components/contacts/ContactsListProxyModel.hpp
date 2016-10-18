#ifndef CONTACTS_LIST_PROXY_MODEL_H
#define CONTACTS_LIST_PROXY_MODEL_H

#include <QSortFilterProxyModel>

#include "ContactsListModel.hpp"

// ===================================================================

class ContactsListProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(
    bool useConnectedFilter
    READ isConnectedFilterUsed
    WRITE setConnectedFilter
  );

public:
  ContactsListProxyModel (QObject *parent = Q_NULLPTR);
  static void initContactsListModel (ContactsListModel *list);

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const;

private:
  float computeStringWeight (const QString &string, float percentage) const;
  float computeContactWeight (const ContactModel &contact) const;

  bool isConnectedFilterUsed () const;
  void setConnectedFilter (bool useConnectedFilter);

  static const QRegExp m_search_separators;

  // The contacts list is shared between `ContactsListProxyModel`
  // it's necessary to initialize it with `initContactsListModel`.
  static ContactsListModel *m_list;

  // It's just a cache to save values computed by `filterAcceptsRow`
  // and reused by `lessThan`.
  mutable QHash<const ContactModel *, int> m_weights;

  bool m_use_connected_filter;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H
