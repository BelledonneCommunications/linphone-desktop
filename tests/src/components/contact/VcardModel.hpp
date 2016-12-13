#ifndef VCARD_MODEL_H_
#define VCARD_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class VcardModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY vcardUpdated);
  Q_PROPERTY(QString avatar READ getAvatar WRITE setAvatar NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantMap address READ getAddress WRITE setAddress NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList sipAddresses READ getSipAddresses NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList companies READ getCompanies NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList emails READ getEmails NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList urls READ getUrls NOTIFY vcardUpdated);

  friend class ContactsListProxyModel;

public:
  VcardModel (std::shared_ptr<linphone::Vcard> vcard) : m_vcard(vcard) {}

  ~VcardModel () = default;

public slots:
  bool addSipAddress (const QString &sip_address);
  void removeSipAddress (const QString &sip_address);
  bool updateSipAddress (const QString &old_sip_address, const QString &sip_address);

  bool addCompany (const QString &company);
  void removeCompany (const QString &company);
  bool updateCompany (const QString &old_company, const QString &company);

  bool addEmail (const QString &email);
  void removeEmail (const QString &email);
  bool updateEmail (const QString &old_email, const QString &email);

  bool addUrl (const QString &url);
  void removeUrl (const QString &url);
  bool updateUrl (const QString &old_url, const QString &url);

signals:
  void vcardUpdated ();

private:
  QString getUsername () const;
  void setUsername (const QString &username);

  QString getAvatar () const;
  void setAvatar (const QString &path);

  QVariantMap getAddress () const;
  void setAddress (const QVariantMap &address);

  QVariantList getSipAddresses () const;
  QVariantList getCompanies () const;
  QVariantList getEmails () const;
  QVariantList getUrls () const;

  std::shared_ptr<linphone::Vcard> m_vcard;
};

Q_DECLARE_METATYPE(VcardModel *);

#endif // VCARD_MODEL_H_
