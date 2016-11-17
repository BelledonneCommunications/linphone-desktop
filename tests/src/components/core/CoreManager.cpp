#include "CoreManager.hpp"

// ===================================================================

CoreManager *CoreManager::m_instance = nullptr;

CoreManager::CoreManager (QObject *parent) :  m_core(
  linphone::Factory::get()->createCore(nullptr, "", "", nullptr)
) {}
