#ifndef SIP_ADDRESSES_MODEL_H_
#define SIP_ADDRESSES_MODEL_H_

#include <QAbstractListModel>

#include "../contact/ContactModel.hpp"
#include "../contact/ContactObserver.hpp"

// =============================================================================

class CoreHandlers;

class SipAddressesModel : public QAbstractListModel {
  Q_OBJECT;

public:
  SipAddressesModel (QObject *parent = Q_NULLPTR);
  ~SipAddressesModel () = default;

  int rowCount (const QModelIndex &index = QModelIndex()) const override;

  QHash<int, QByteArray> roleNames () const override;
  QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;

  Q_INVOKABLE ContactModel *mapSipAddressToContact (const QString &sip_address) const;
  Q_INVOKABLE ContactObserver *getContactObserver (const QString &sip_address);

  Q_INVOKABLE void handleAllHistoryEntriesRemoved ();

  Q_INVOKABLE QString interpretUrl (const QString &sip_address);

private:
  bool removeRow (int row, const QModelIndex &parent = QModelIndex());
  bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

  void handleContactAdded (ContactModel *contact);
  void handleContactRemoved (const ContactModel *contact);

  void handleReceivedMessage (
    const std::shared_ptr<linphone::ChatRoom> &room,
    const std::shared_ptr<linphone::ChatMessage> &message
  );

  void addOrUpdateSipAddress (const QString &sip_address, ContactModel *contact = nullptr, qint64 timestamp = 0);
  void removeContactOfSipAddress (const QString &sip_address);

  void initSipAddresses ();

  void updateObservers (const QString &sip_address, ContactModel *contact);

  QHash<QString, QVariantMap> m_sip_addresses;
  QList<const QVariantMap *> m_refs;

  QMultiHash<QString, ContactObserver *> m_observers;

  std::shared_ptr<CoreHandlers> m_handlers;
};

#endif // SIP_ADDRESSES_MODEL_H_
