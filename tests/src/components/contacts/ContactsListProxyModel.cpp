#include <QDebug>

#include "ContactsListProxyModel.hpp"

#define USERNAME_WEIGHT 0.5
#define MAIN_SIP_ADDRESS_WEIGHT 0.3
#define OTHER_SIP_ADDRESSES_WEIGHT 0.2

// ===================================================================

ContactsListModel *ContactsListProxyModel::m_list = nullptr;

ContactsListProxyModel::ContactsListProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(m_list);
  setDynamicSortFilter(true);
  setFilterCaseSensitivity(Qt::CaseInsensitive);

  foreach (const ContactModel *contact, m_list->m_list)
    m_weights[contact] = 0;

  sort(0);
}

void ContactsListProxyModel::initContactsListModel (ContactsListModel *list) {
  if (!m_list)
    m_list = list;
  else
    qWarning() << "Contacts list model is already defined.";
}

bool ContactsListProxyModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  const ContactModel *contact = qvariant_cast<ContactModel *>(
    index.data(ContactsListModel::ContactRole)
  );

  int weight = m_weights[contact] = computeContactWeight(*contact);
  return weight > 0;
}

bool ContactsListProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ContactModel *contact_a = qvariant_cast<ContactModel *>(
    sourceModel()->data(left, ContactsListModel::ContactRole)
  );
  const ContactModel *contact_b = qvariant_cast<ContactModel *>(
    sourceModel()->data(right, ContactsListModel::ContactRole)
  );

  float weight_a = m_weights[contact_a];
  float weight_b = m_weights[contact_b];

  // Sort by weight and name.
  return (
    weight_a > weight_b ||
    (weight_a == weight_b && contact_a->m_username <= contact_b->m_username)
  );
}

float ContactsListProxyModel::computeContactWeight (const ContactModel &contact) const {
  float weight = 0;

  if (filterRegExp().indexIn(contact.m_username) != -1)
    weight += USERNAME_WEIGHT;

  const QStringList &addresses = contact.m_sip_addresses;

  if (filterRegExp().indexIn(addresses[0]) != -1)
    weight += MAIN_SIP_ADDRESS_WEIGHT;

  int size = addresses.size();

  if (size > 1)
    for (auto it = ++addresses.constBegin(); it != addresses.constEnd(); ++it)
      if (filterRegExp().indexIn(*it) != -1)
        weight += OTHER_SIP_ADDRESSES_WEIGHT / size;

  return weight;
}
