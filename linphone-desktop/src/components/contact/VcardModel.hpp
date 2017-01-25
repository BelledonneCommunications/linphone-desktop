#ifndef VCARD_MODEL_H_
#define VCARD_MODEL_H_

#include <linphone++/linphone.hh>
#include <QObject>

// =============================================================================

class VcardModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString username READ getUsername WRITE setUsername NOTIFY vcardUpdated);
  Q_PROPERTY(QString avatar READ getAvatar WRITE setAvatar NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantMap address READ getAddress NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList sipAddresses READ getSipAddresses NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList companies READ getCompanies NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList emails READ getEmails NOTIFY vcardUpdated);
  Q_PROPERTY(QVariantList urls READ getUrls NOTIFY vcardUpdated);

  friend class ContactModel;

public:
  VcardModel (std::shared_ptr<linphone::Vcard> vcard) : m_vcard(vcard) {}

  ~VcardModel ();

  QString getUsername () const;
  QVariantList getSipAddresses () const;

  Q_INVOKABLE bool addSipAddress (const QString &sip_address);
  Q_INVOKABLE void removeSipAddress (const QString &sip_address);
  Q_INVOKABLE bool updateSipAddress (const QString &old_sip_address, const QString &sip_address);

  Q_INVOKABLE bool addCompany (const QString &company);
  Q_INVOKABLE void removeCompany (const QString &company);
  Q_INVOKABLE bool updateCompany (const QString &old_company, const QString &company);

  Q_INVOKABLE bool addEmail (const QString &email);
  Q_INVOKABLE void removeEmail (const QString &email);
  Q_INVOKABLE bool updateEmail (const QString &old_email, const QString &email);

  Q_INVOKABLE bool addUrl (const QString &url);
  Q_INVOKABLE void removeUrl (const QString &url);
  Q_INVOKABLE bool updateUrl (const QString &old_url, const QString &url);

  Q_INVOKABLE void setStreet (const QString &street);
  Q_INVOKABLE void setLocality (const QString &locality);
  Q_INVOKABLE void setPostalCode (const QString &postal_code);
  Q_INVOKABLE void setCountry (const QString &country);

signals:
  void vcardUpdated ();

private:
  void setUsername (const QString &username);

  QString getAvatar () const;
  bool setAvatar (const QString &path);

  QVariantMap getAddress () const;
  QVariantList getCompanies () const;
  QVariantList getEmails () const;
  QVariantList getUrls () const;

  std::shared_ptr<linphone::Vcard> m_vcard;
};

Q_DECLARE_METATYPE(VcardModel *);

#endif // VCARD_MODEL_H_
