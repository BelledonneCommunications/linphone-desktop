#include "TimelineModel.hpp"

// ===================================================================

TimelineModel::TimelineModel (QObject *parent): QAbstractListModel(parent) {
  // TMP.
  m_addresses << "toto.linphone.sip.linphone.org";
  m_addresses << "toto1.linphone.sip.linphone.org";
  m_addresses << "toto2.linphone.sip.linphone.org";
  m_addresses << "toto3.linphone.sip.linphone.org";
  m_addresses << "toto4.linphone.sip.linphone.org";
  m_addresses << "toto5.linphone.sip.linphone.org";
  m_addresses << "toto6.linphone.sip.linphone.org";
  m_addresses << "toto7.linphone.sip.linphone.org";
  m_addresses << "toto8.linphone.sip.linphone.org";
  m_addresses << "toto9.linphone.sip.linphone.org";
  m_addresses << "toto10.linphone.sip.linphone.org";
  m_addresses << "toto11.linphone.sip.linphone.org";
}

int TimelineModel::rowCount (const QModelIndex &) const {
  return m_addresses.count();
}

QHash<int, QByteArray> TimelineModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$timelineEntry";
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
