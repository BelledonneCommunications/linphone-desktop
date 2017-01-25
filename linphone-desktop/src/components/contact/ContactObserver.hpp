#ifndef CONTACT_OBSERVER_H_
#define CONTACT_OBSERVER_H_

#include <QObject>

// =============================================================================

class ContactModel;

class ContactObserver : public QObject {
  friend class SipAddressesModel;

  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress CONSTANT);
  Q_PROPERTY(ContactModel * contact READ getContact NOTIFY contactChanged);

public:
  ContactObserver (const QString &sip_address);
  ~ContactObserver () = default;

  ContactModel *getContact () const {
    return m_contact;
  }

signals:
  void contactChanged (ContactModel *contact);

private:
  QString getSipAddress () const {
    return m_sip_address;
  }

  void setContact (ContactModel *contact);

  QString m_sip_address;
  ContactModel *m_contact = nullptr;
};

Q_DECLARE_METATYPE(ContactObserver *);

#endif // CONTACT_OBSERVER_H_
