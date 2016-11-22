#ifndef CONTACTS_LIST_MODEL_H
#define CONTACTS_LIST_MODEL_H

#include <QAbstractListModel>

#include "ContactModel.hpp"

// ===================================================================

class ContactsListModel : public QAbstractListModel {
  friend class ContactsListProxyModel;

  Q_OBJECT;

public:
  ContactsListModel (QObject *parent = Q_NULLPTR);

  int rowCount (const QModelIndex &) const {
    return m_list.count();
  }

  QHash<int, QByteArray> roleNames () const;
  QVariant data (const QModelIndex &index, int role) const;

  ContactModel *mapLinphoneFriendToContact (
    const std::shared_ptr<linphone::Friend> &friend_
  ) const;

public slots:
  ContactModel *mapSipAddressToContact (const QString &sipAddress) const;

private:
  QList<ContactModel *> m_list;
  QHash<const linphone::Friend *, ContactModel* > m_friend_to_contact;

  std::shared_ptr<linphone::FriendList> m_linphone_friends;
};

#endif // CONTACTS_LIST_MODEL_H
