#include "SmartSearchBarProxyModel.hpp"

// =============================================================================

void SmartSearchBarProxyModel::setFilter (const QString &pattern) {
  m_contacts.setFilter(pattern);
  m_sip_addresses.setFilter(pattern);
}
