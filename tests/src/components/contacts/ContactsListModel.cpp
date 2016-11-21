#include "../core/CoreManager.hpp"
#include "ContactsListProxyModel.hpp"

#include "ContactsListModel.hpp"

using namespace std;

// ===================================================================

ContactsListModel::ContactsListModel (QObject *parent): QAbstractListModel(parent) {
  shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());

  // Init contacts with linphone friends list.
  for (auto&& contact : core->getFriendsLists().front()->getFriends()) {
    m_list << new ContactModel(contact);
  }
}

QHash<int, QByteArray> ContactsListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$contact";
  return roles;
}

QVariant ContactsListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (row < 0 || row >= m_list.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(m_list[row]);

  return QVariant();
}

// -------------------------------------------------------------------

ContactModel *ContactsListModel::mapSipAddressToContact (const QString &sipAddress) {
  return ContactsListProxyModel::getContactsListModel()->m_list.front();
}
