#include "../contact/ContactModel.hpp"

#include "ContactObserver.hpp"

// =============================================================================

ContactObserver::ContactObserver (const QString &sip_address) {
  m_sip_address = sip_address;
}

void ContactObserver::setContact (ContactModel *contact) {
  m_contact = contact;
  emit contactChanged(contact);
}
