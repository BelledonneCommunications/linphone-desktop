#ifndef SMART_SEARCH_BAR_PROXY_MODEL_H_
#define SMART_SEARCH_BAR_PROXY_MODEL_H_

#include "SmartSearchBarModel.hpp"

// =============================================================================

class SmartSearchBarProxyModel : public SmartSearchBarModel {
  Q_OBJECT;

public:
  SmartSearchBarProxyModel (QObject *parent = Q_NULLPTR) : SmartSearchBarModel(parent) {}

  ~SmartSearchBarProxyModel () = default;

public slots:
  void setFilter (const QString &pattern);
};

#endif // SMART_SEARCH_BAR_PROXY_MODEL_H_
