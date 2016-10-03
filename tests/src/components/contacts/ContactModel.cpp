#include "ContactModel.hpp"

// ===================================================================

ContactModel::PresenceLevel ContactModel:: getPresenceLevel () const {
  if (m_presence == Online)
    return Green;
  if (m_presence == DoNotDisturb)
    return Red;
  if (m_presence == Offline)
    return White;

  return Orange;
}
