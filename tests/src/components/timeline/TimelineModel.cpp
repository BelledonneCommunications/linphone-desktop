#include "TimelineModel.hpp"

// ===================================================================

TimelineModel::TimelineModel (QObject *parent): QAbstractListModel(parent) {
  // TMP.
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto.linphone.sip.linphone.org";
}

int TimelineModel::rowCount (const QModelIndex &) const {
  return m_addresses.count();
}

QHash<int, QByteArray> TimelineModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$address";
  return roles;
}

QVariant TimelineModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (row < 0 || row >= m_addresses.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(m_addresses[row]);

  return QVariant();
}
