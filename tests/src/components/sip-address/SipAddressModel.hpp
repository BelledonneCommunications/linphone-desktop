#ifndef SIP_ADDRESS_MODEL_H_
#define SIP_ADDRESS_MODEL_H_

#include <QObject>

// =============================================================================

class ContactModel;

class SipAddressModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(QString sipAddress READ getSipAddress CONSTANT);
  Q_PROPERTY(ContactModel * contact READ getContact NOTIFY contactChanged);

public:
  SipAddressModel ();
  ~SipAddressModel () = default;

  ContactModel *getContact () const {
    return m_contact;
  }

signals:
  void contactChanged (ContactModel *contact);

private:
  QString getSipAddress () const {
    return m_sip_address;
  }

  QString m_sip_address;
  ContactModel *m_contact = nullptr;
};

Q_DECLARE_METATYPE(SipAddressModel *);

#endif // SIP_ADDRESS_MODEL_H_
