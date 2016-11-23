#ifndef CONTACTS_LIST_MODEL_H_
#define CONTACTS_LIST_MODEL_H_

#include <QAbstractListModel>

#include "ContactModel.hpp"

// ===================================================================

class ContactsListModel : public QAbstractListModel {
  friend class ContactsListProxyModel;

  Q_OBJECT;

public:
  ContactsListModel (QObject *parent = Q_NULLPTR);

  int rowCount (const QModelIndex &index = QModelIndex()) const {
    return m_list.count();
  }

  QHash<int, QByteArray> roleNames () const;
  QVariant data (const QModelIndex &index, int role) const;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex());

public slots:
  // See: http://doc.qt.io/qt-5/qtqml-cppintegration-data.html#data-ownership
  // The returned value must have a explicit parent or a QQmlEngine::CppOwnership.
  ContactModel *mapSipAddressToContact (const QString &sipAddress) const;

  void removeContact (ContactModel *contact);

private:
  QList<ContactModel *> m_list;
  QHash<const linphone::Friend *, ContactModel *> m_friend_to_contact;

  std::shared_ptr<linphone::FriendList> m_linphone_friends;
};

#endif // CONTACTS_LIST_MODEL_H_
