#ifndef CONTACTS_LIST_MODEL_H_
#define CONTACTS_LIST_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>

#include "../contact/ContactModel.hpp"

// =============================================================================

class ContactsListModel : public QAbstractListModel {
  friend class SipAddressesModel;

  Q_OBJECT;

public:
  ContactsListModel (QObject *parent = Q_NULLPTR);
  ~ContactsListModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  Q_INVOKABLE ContactModel *addContact (VcardModel *vcard);
  Q_INVOKABLE void removeContact (ContactModel *contact);

signals:
  void contactAdded (ContactModel *contact);
  void contactRemoved (const ContactModel *contact);
  void contactUpdated (ContactModel *contact);

  void sipAddressAdded (ContactModel *contact, const QString &sip_address);
  void sipAddressRemoved (ContactModel *contact, const QString &sip_address);

private:
  void addContact (ContactModel *contact);

  QList<ContactModel *> m_list;
  std::shared_ptr<linphone::FriendList> m_linphone_friends;
};

#endif // CONTACTS_LIST_MODEL_H_
