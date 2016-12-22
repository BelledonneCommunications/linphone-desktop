#ifndef SMART_SEARCH_BAR_MODEL_H_
#define SMART_SEARCH_BAR_MODEL_H_

#include <QAbstractListModel>

#include "../contacts/ContactsListProxyModel.hpp"
#include "../sip-addresses/UnregisteredSipAddressesProxyModel.hpp"

// =============================================================================

class SmartSearchBarModel : public QAbstractListModel {
  Q_OBJECT;

public:
  SmartSearchBarModel (QObject *parent = Q_NULLPTR) : QAbstractListModel(parent) {}

  virtual ~SmartSearchBarModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

protected:
  ContactsListProxyModel m_contacts;
  UnregisteredSipAddressesProxyModel m_sip_addresses;
};

#endif // SMART_SEARCH_BAR_MODEL_H_
