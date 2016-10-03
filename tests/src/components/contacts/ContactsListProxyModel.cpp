#include <QDebug>

#include "ContactsListProxyModel.hpp"

// ===================================================================

ContactsListModel *ContactsListProxyModel::m_list = nullptr;

ContactsListProxyModel::ContactsListProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(m_list);
  setDynamicSortFilter(true);
  sort(0);
}

void ContactsListProxyModel::initContactsListModel (ContactsListModel *list) {
  if (!m_list)
    m_list = list;
  else
    qWarning() << "Contacts list model already defined.";
}

bool ContactsListProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  const ContactModel *contact = qvariant_cast<ContactModel *>(
    index.data(ContactsListModel::ContactRole)
  );

  qDebug() << "A";

  return contact->getUsername().contains(
    filterRegExp().pattern(),
    Qt::CaseInsensitive
  );
}

bool ContactsListProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {

  qDebug() << "B";

  return true;
}
