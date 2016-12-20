#ifndef CONTACTS_LIST_MODEL_H_
#define CONTACTS_LIST_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>

#include "../contact/ContactModel.hpp"

// =============================================================================

class ContactsListModel : public QAbstractListModel {
  Q_OBJECT;

  friend class ContactsListProxyModel;

public:
  ~ContactsListModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  static void init () {
    if (!ContactsListModel::m_instance) {
      m_instance = new ContactsListModel();
    }
  }

  static ContactsListModel *getInstance () {
    return m_instance;
  }

public slots:
  ContactModel *mapSipAddressToContact (const QString &sipAddress) const;

  ContactModel *addContact (VcardModel *vcard);
  void removeContact (ContactModel *contact);

private:
  ContactsListModel (QObject *parent = Q_NULLPTR);

  QList<ContactModel *> m_list;
  std::shared_ptr<linphone::FriendList> m_linphone_friends;

  static ContactsListModel *m_instance;
};

#endif // CONTACTS_LIST_MODEL_H_
