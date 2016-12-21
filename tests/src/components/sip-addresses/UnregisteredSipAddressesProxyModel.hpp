#ifndef UNREGISTERED_SIP_ADDRESSES_PROXY_MODEL_H_
#define UNREGISTERED_SIP_ADDRESSES_PROXY_MODEL_H_

#include "UnregisteredSipAddressesModel.hpp"

// =============================================================================

class UnregisteredSipAddressesProxyModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  UnregisteredSipAddressesProxyModel (QObject *parent = Q_NULLPTR);
  ~UnregisteredSipAddressesProxyModel () = default;

public slots:
  void setFilter (const QString &pattern) {
    setFilterFixedString(pattern);
    invalidate();
  }

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;

private:
  int computeStringWeight (const QString &string) const;

  static const QRegExp m_search_separators;
};

#endif // UNREGISTERED_SIP_ADDRESSES_PROXY_MODEL_H_
