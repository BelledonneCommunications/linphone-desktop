#ifndef CONTACTS_LIST_PROXY_MODEL_H_
#define CONTACTS_LIST_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

#include "ContactsListModel.hpp"

// =============================================================================

class ContactsListProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

  Q_PROPERTY(
    bool useConnectedFilter
    READ isConnectedFilterUsed
    WRITE setConnectedFilter
  );

public:
  ContactsListProxyModel (QObject *parent = Q_NULLPTR);
  ~ContactsListProxyModel () = default;

  static void initContactsListModel (ContactsListModel *list);
  static ContactsListModel *getContactsListModel () {
    return m_list;
  }

public slots:
  void setFilter (const QString &pattern) {
    setFilterFixedString(pattern);
    sort(0);
  }

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;

private:
  float computeStringWeight (const QString &string, float percentage) const;
  float computeContactWeight (const ContactModel &contact) const;

  bool isConnectedFilterUsed () const {
    return m_use_connected_filter;
  }

  void setConnectedFilter (bool use_connected_filter);

  // It's just a cache to save values computed by `filterAcceptsRow`
  // and reused by `lessThan`.
  mutable QHash<const ContactModel *, unsigned int> m_weights;

  bool m_use_connected_filter;

  static const QRegExp m_search_separators;

  // The contacts list is shared between `ContactsListProxyModel`
  // it's necessary to initialize it with `initContactsListModel`.
  static ContactsListModel *m_list;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H_
