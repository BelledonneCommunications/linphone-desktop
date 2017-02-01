#ifndef CONTACTS_LIST_PROXY_MODEL_H_
#define CONTACTS_LIST_PROXY_MODEL_H_

#include "../contact/ContactModel.hpp"

#include <QSortFilterProxyModel>

// =============================================================================

class ContactsListModel;

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

  Q_INVOKABLE void setFilter (const QString &pattern);

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

  QString m_filter;
  bool m_use_connected_filter = false;

  // It's just a cache to save values computed by `filterAcceptsRow`
  // and reused by `lessThan`.
  mutable QHash<const ContactModel *, unsigned int> m_weights;

  static const QRegExp m_search_separators;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H_
