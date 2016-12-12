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

  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY contactUpdated);
  Q_PROPERTY(QString avatar READ getAvatar WRITE setAvatar NOTIFY contactUpdated);
  Q_PROPERTY(QVariantList sipAddresses READ getSipAddresses NOTIFY contactUpdated);
  Q_PROPERTY(QVariantList companies READ getCompanies NOTIFY contactUpdated);
  Q_PROPERTY(QVariantList emails READ getEmails NOTIFY contactUpdated);
  Q_PROPERTY(QVariantList urls READ getUrls NOTIFY contactUpdated);
  Q_PROPERTY(QVariantMap address READ getAddress WRITE setAddress NOTIFY contactUpdated);

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
  ContactModel (
    std::shared_ptr<linphone::Friend> linphone_friend,
    bool is_detached = false
  );

public slots:

  bool addSipAddress (const QString &sip_address);
  void removeSipAddress (const QString &sip_address);
  bool updateSipAddress (const QString &old_sip_address, const QString &sip_address);

  void addCompany (const QString &company);
  void removeCompany (const QString &company);
  void updateCompany (const QString &old_company, const QString &company);

  bool addEmail (const QString &email);
  void removeEmail (const QString &email);
  bool updateEmail (const QString &old_email, const QString &email);

  bool addUrl (const QString &url);
  void removeUrl (const QString &url);
  bool updateUrl (const QString &old_url, const QString &url);

signals:
  void contactUpdated ();

private:
  void edit ();
  void done ();

  QString getUsername () const;
  void setUsername (const QString &username);

  QString getAvatar () const;
  void setAvatar (const QString &path);

  QVariantList getSipAddresses () const;
  QVariantList getCompanies () const;
  QVariantList getEmails () const;
  QVariantList getUrls () const;

  QVariantMap getAddress () const;
  void setAddress (const QVariantMap &address);

  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  // TODO: Remove!!!
  QString getSipAddress () const;

  bool m_is_detached;

  Presence::PresenceStatus m_presence_status = Presence::Offline;

  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel*);

#endif // CONTACT_MODEL_H_
