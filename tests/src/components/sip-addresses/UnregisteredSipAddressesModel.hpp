#ifndef UNREGISTERED_SIP_ADDRESSES_MODEL_H_
#define UNREGISTERED_SIP_ADDRESSES_MODEL_H_

#include <QSortFilterProxyModel>

// =============================================================================

class UnregisteredSipAddressesModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  UnregisteredSipAddressesModel (QObject *parent = Q_NULLPTR);
  ~UnregisteredSipAddressesModel () = default;

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override;
};

 #endif // UNREGISTERED_SIP_ADDRESSES_MODEL_H_
