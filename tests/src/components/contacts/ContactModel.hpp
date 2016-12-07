#ifndef CONTACT_MODEL_H_
#define CONTACT_MODEL_H_

#include <QObject>
#include <linphone++/linphone.hh>

#include "../presence/Presence.hpp"

// ===================================================================

class ContactModel : public QObject {
  friend class ContactsListModel;
  friend class ContactsListProxyModel;

  Q_OBJECT;

  Q_PROPERTY(
    QString username
    READ getUsername
    WRITE setUsername
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QString avatar
    READ getAvatar
    WRITE setAvatar
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QVariantList sipAddresses
    READ getSipAddresses
    WRITE setSipAddresses
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QVariantList companies
    READ getCompanies
    WRITE setCompanies
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QVariantList emails
    READ getEmails
    WRITE setEmails
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QVariantList urls
    READ getUrls
    WRITE setUrls
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QList<QVariantMap> addresses
    READ getAddresses
    WRITE setAddresses
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    Presence::PresenceStatus presenceStatus
    READ getPresenceStatus
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    Presence::PresenceLevel presenceLevel
    READ getPresenceLevel
    NOTIFY contactUpdated
  );

  Q_PROPERTY(
    QString sipAddress
    READ getSipAddress
    NOTIFY contactUpdated
  );

public:
  ContactModel (std::shared_ptr<linphone::Friend> linphone_friend);

signals:
  void contactUpdated ();

private:
  QString getUsername () const;
  bool setUsername (const QString &username);

  QString getAvatar () const;
  bool setAvatar (const QString &path);

  QVariantList getSipAddresses () const;
  void setSipAddresses (const QVariantList &sip_addresses);

  QVariantList getCompanies () const;
  void setCompanies (const QVariantList &companies);

  QVariantList getEmails () const;
  void setEmails (const QVariantList &emails);

  QVariantList getUrls () const;
  void setUrls (const QVariantList &urls);

  QList<QVariantMap> getAddresses () const;
  void setAddresses (const QList<QVariantMap> &addresses);

  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  QString getSipAddress () const;

  Presence::PresenceStatus m_presence_status = Presence::Offline;

  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H_
