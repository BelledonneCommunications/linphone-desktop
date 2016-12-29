#include "../core/CoreManager.hpp"

#include "SmartSearchBarModel.hpp"

#define WEIGHT_POS_0 5
#define WEIGHT_POS_1 4
#define WEIGHT_POS_2 3
#define WEIGHT_POS_3 2
#define WEIGHT_POS_OTHER 1

// =============================================================================

const QRegExp SmartSearchBarModel::m_search_separators("^[^_.-;@ ][_.-;@ ]");

// -----------------------------------------------------------------------------

SmartSearchBarModel::SmartSearchBarModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getSipAddressesModel());
  sort(0);
}

QHash<int, QByteArray> SmartSearchBarModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$entry";
  return roles;
}

// -----------------------------------------------------------------------------

void SmartSearchBarModel::setFilter (const QString &pattern) {
  m_filter = pattern;
  invalidate();
}

// -----------------------------------------------------------------------------

bool SmartSearchBarModel::filterAcceptsRow (int source_row, const QModelIndex &source_parent) const {
  const QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
  const QVariantMap map = index.data().toMap();

  return computeStringWeight(map["sipAddress"].toString()) > 0;
}

bool SmartSearchBarModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const QVariantMap map_a = sourceModel()->data(left).toMap();
  const QVariantMap map_b = sourceModel()->data(right).toMap();

  const QString sip_address_a = map_a["sipAddress"].toString();
  const QString sip_address_b = map_b["sipAddress"].toString();

  int weight_a = computeStringWeight(sip_address_a);
  int weight_b = computeStringWeight(sip_address_b);

  // 1. Not the same weight.
  if (weight_a != weight_b)
    return weight_a > weight_b;

  const ContactModel *contact_a = map_a.value("contact").value<ContactModel *>();
  const ContactModel *contact_b = map_b.value("contact").value<ContactModel *>();

  // 2. No contacts.
  if (!contact_a && !contact_b)
    return sip_address_a <= sip_address_b;

  // 3. No contact for a or b.
  if (!contact_a || !contact_b)
    return !!contact_a;

  // 4. Same contact (address).
  if (contact_a == contact_b)
    return sip_address_a <= sip_address_b;

  // 5. Not the same contact name.
  int diff = contact_a->m_linphone_friend->getName().compare(contact_b->m_linphone_friend->getName());
  if (diff)
    return diff <= 0;

  // 6. Same contact name, so compare sip addresses.
  return sip_address_a <= sip_address_b;
}

int SmartSearchBarModel::computeStringWeight (const QString &string) const {
  int index = -1;
  int offset = -1;

  while ((index = string.indexOf(m_filter, index + 1, Qt::CaseInsensitive)) != -1) {
    int tmp_offset = index - string.lastIndexOf(m_search_separators, index) - 1;
    if ((tmp_offset != -1 && tmp_offset < offset) || offset == -1)
      if ((offset = tmp_offset) == 0) break;
  }

  switch (offset) {
    case -1: return 0;
    case 0: return WEIGHT_POS_0;
    case 1: return WEIGHT_POS_1;
    case 2: return WEIGHT_POS_2;
    case 3: return WEIGHT_POS_3;
    default: break;
  }

  return WEIGHT_POS_OTHER;
}
