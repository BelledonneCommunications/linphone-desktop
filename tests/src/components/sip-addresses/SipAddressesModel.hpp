#ifndef SIP_ADDRESSES_MODEL_H_
#define SIP_ADDRESSES_MODEL_H_

#include <QAbstractListModel>

#include "../contact/ContactModel.hpp"

// =============================================================================

class SipAddressesModel : public QAbstractListModel {
  Q_OBJECT;

public:
  SipAddressesModel (QObject *parent = Q_NULLPTR);
  ~SipAddressesModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role) const override;

public slots:
  ContactModel *mapSipAddressToContact (const QString &sip_address) const;
  void handleAllHistoryEntriesRemoved ();

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  void updateFromNewContact (ContactModel *contact);
  void updateFromNewContactSipAddress (ContactModel *contact, const QString &sip_address);
  void tryToRemoveSipAddress (const QString &sip_address);

  void fetchSipAddresses ();

  QHash<QString, QVariantMap> m_sip_addresses;
  QList<const QVariantMap *> m_refs;
};

#endif // SIP_ADDRESSES_MODEL_H_
