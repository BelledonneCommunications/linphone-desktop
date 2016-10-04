#include "ContactsListModel.hpp"

// ===================================================================

ContactsListModel::ContactsListModel (QObject *parent): QAbstractListModel(parent) {
  // TMP.
  m_list << new ContactModel("Toto Roi", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Mary Boreno", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Cecelia Cyler", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Daniel Elliott", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Effie Forton", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Agnes Hurner", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Luke  Lemin", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Claire Manning", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Isabella Ahornton", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Mary Boreno", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("Aman Than", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));
  m_list << new ContactModel("  abdoul", "", Presence::Online, QStringList("toto.linphone.sip.linphone.org"));

}

int ContactsListModel::rowCount (const QModelIndex &) const {
  return m_list.count();
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
