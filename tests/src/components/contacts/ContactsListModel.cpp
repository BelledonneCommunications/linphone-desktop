#include "../core/CoreManager.hpp"
#include "ContactsListProxyModel.hpp"

#include "ContactsListModel.hpp"

using namespace std;

// ===================================================================

ContactsListModel::ContactsListModel (QObject *parent): QAbstractListModel(parent) {
  shared_ptr<linphone::Core> core(CoreManager::getInstance()->getCore());

  // Init contacts with linphone friends list.
  for (const auto &friend_ : core->getFriendsLists().front()->getFriends()) {
    ContactModel *contact = new ContactModel(friend_);
    m_friend_to_contact[friend_.get()] = contact;
    m_list << contact;
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
  return m_friend_to_contact[
    CoreManager::getInstance()->getCore()->getFriendsLists().front()->findFriendByUri(
      sipAddress.toStdString()
    ).get()
  ];
}
