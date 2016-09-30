#include "ContactsListModel.hpp"

// ===================================================================

ContactsListModel::ContactsListModel (QObject *parent): QAbstractListModel(parent) {
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

int ContactsListModel::rowCount (const QModelIndex &) const {
  return m_list.count();
}

QHash<int, QByteArray> ContactsListModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[ContactRole] = "$contact";
  return roles;
}

QVariant ContactsListModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (row < 0 || row >= m_list.count())
    return QVariant();

  if (role == ContactRole)
    return QVariant::fromValue(m_list[row]);

  return QVariant();
}
