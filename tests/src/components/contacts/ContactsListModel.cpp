#include <QtDebug>

#include "../../app/App.hpp"
#include "../core/CoreManager.hpp"
#include "ContactsListProxyModel.hpp"

#include "ContactsListModel.hpp"

using namespace std;

// ===================================================================

ContactsListModel::ContactsListModel (QObject *parent): QAbstractListModel(parent) {
  m_linphone_friends = CoreManager::getInstance()->getCore()->getFriendsLists().front();

  // Init contacts with linphone friends list.
  for (const auto &friend_ : m_linphone_friends->getFriends()) {
    ContactModel *contact = new ContactModel(friend_);
    App::getInstance()->getEngine()->setObjectOwnership(
      contact, QQmlEngine::CppOwnership
    );

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

bool ContactsListModel::removeRow (int row, const QModelIndex &) {
  return removeRows(row, 1);
}

bool ContactsListModel::removeRows (int row, int count, const QModelIndex &parent) {
  int limit = row + count - 1;

  if (row < 0 || count < 0 || limit >= m_list.count())
    return false;

  beginRemoveRows(parent, row, limit);

  for (int i = 0; i < count; ++i) {
    ContactModel *contact = m_list[row];

    m_list.removeAt(row);
    m_friend_to_contact.remove(contact->m_linphone_friend.get());
    // m_linphone_friends->removeFriend(contact->m_linphone_friend);

    contact->deleteLater();
  }

  endRemoveRows();

  return true;
}

// -------------------------------------------------------------------

ContactModel *ContactsListModel::mapSipAddressToContact (const QString &sipAddress) const {
  // Maybe use a hashtable in future version to get a lower cost?
  ContactModel *contact = m_friend_to_contact.value(
    m_linphone_friends->findFriendByUri(
      sipAddress.toStdString()
    ).get()
  );

  qInfo() << "Map sip address to contact:" << sipAddress << "->" << contact;

  return contact;
}

void ContactsListModel::removeContact (ContactModel *contact) {
  qInfo() << "Removing contact:" << contact;

  int index = m_list.indexOf(contact);
  if (index == -1 || !removeRow(index))
    qWarning() << "Unable to remove contact:" << index;
}
