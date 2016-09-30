#ifndef CONTACTS_LIST_MODEL_H
#define CONTACTS_LIST_MODEL_H

#include <QAbstractListModel>

#include "ContactModel.hpp"

// ===================================================================

class ContactsListModel : public QAbstractListModel {
  Q_OBJECT

public:
  enum Roles {
    ContactRole = Qt::UserRole + 1
  };

  ContactsListModel (QObject *parent = Q_NULLPTR): QAbstractListModel(parent) {
    m_list << new ContactModel("Toto Roi", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Mary Boreno", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Cecelia Cyler", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Daniel Elliott", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Effie Forton", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Agnes Hurner", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Luke Lemin", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Olga Manning", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Isabella Ahornton", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
    m_list << new ContactModel("Mary Boreno", "", ContactModel::Online, QStringList("toto.linphone.sip.linphone.org"));
  }

  int rowCount (const QModelIndex &) const {
    return m_list.count();
  }

  QHash<int, QByteArray> roleNames () const {
    QHash<int, QByteArray> roles;
    roles[ContactRole] = "$contact";
    return roles;
  }

  QVariant data (const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() >= m_list.count())
      return QVariant();

    if (role == ContactRole)
      return QVariant::fromValue(m_list[index.row()]);

    return QVariant();
  }

private:
  QList<ContactModel *> m_list;
};

#endif // CONTACTS_LIST_MODEL_H
