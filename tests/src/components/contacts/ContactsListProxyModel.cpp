#include "ContactsListProxyModel.hpp"

#include <QDebug>

// ===================================================================

bool ContactsListProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  const ContactModel *contact = qvariant_cast<ContactModel *>(
    index.data(ContactsListModel::ContactRole)
  );

  return contact->getUsername().contains(
    filterRegExp().pattern(),
    Qt::CaseInsensitive
  );
}
