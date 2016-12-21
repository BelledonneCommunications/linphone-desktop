#include "SmartSearchBarModel.hpp"

// =============================================================================

int SmartSearchBarModel::rowCount (const QModelIndex &) const {
  return m_contacts.rowCount() + m_sip_addresses.rowCount();
}

QHash<int, QByteArray> SmartSearchBarModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$entry";
  return roles;
}

QVariant SmartSearchBarModel::data (const QModelIndex &index, int role) const {
  int row = index.row();
  int n_contacts = m_contacts.rowCount();
  int n_sip_addresses = m_sip_addresses.rowCount();

  if (row < 0 || row >= n_contacts + n_sip_addresses)
    return QVariant();

  if (role == Qt::DisplayRole) {
    if (row < n_contacts)
      return QVariant::fromValue(m_contacts.data(m_contacts.index(row, 0), role));

    return QVariant::fromValue(m_sip_addresses.data(m_sip_addresses.index(row - n_contacts, 0), role));
  }

  return QVariant();
}
