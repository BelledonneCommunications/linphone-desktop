#ifndef CONTACTS_LIST_PROXY_MODEL_H
#define CONTACTS_LIST_PROXY_MODEL_H

#include <QSortFilterProxyModel>

#include "ContactsListModel.hpp"

// ===================================================================

class ContactsListProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  ContactsListProxyModel (QObject *parent = Q_NULLPTR) : QSortFilterProxyModel(parent) {
    setSourceModel(&m_list);
    setDynamicSortFilter(true);
    sort(0);
  }

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const;

private:
  ContactsListModel m_list;
};

#endif // CONTACTS_LIST_PROXY_MODEL_H
