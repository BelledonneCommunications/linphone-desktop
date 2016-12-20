#ifndef CONTACT_MODEL_H_
#define CONTACT_MODEL_H_

#include "../presence/Presence.hpp"
#include "VcardModel.hpp"

// =============================================================================

class ContactModel : public QObject {
  Q_OBJECT;

  Q_PROPERTY(Presence::PresenceStatus presenceStatus READ getPresenceStatus NOTIFY contactUpdated);
  Q_PROPERTY(Presence::PresenceLevel presenceLevel READ getPresenceLevel NOTIFY contactUpdated);
  Q_PROPERTY(VcardModel * vcard READ getVcardModelPtr NOTIFY contactUpdated);

  friend class ContactsListModel;
  friend class ContactsListProxyModel;

public:
  ContactModel (std::shared_ptr<linphone::Friend> linphone_friend);
  ContactModel (VcardModel *vcard);
  ~ContactModel () = default;

  std::shared_ptr<VcardModel> getVcardModel () const {
    return m_vcard;
  }

public slots:
  void startEdit () {
    m_linphone_friend->edit();
  }

  void endEdit () {
    m_linphone_friend->done();
  }

  void abortEdit () {
    // TODO: call linphone friend abort function.
    // m_linphone_friend->abort();
  }

signals:
  void contactUpdated ();

private:
  Presence::PresenceStatus getPresenceStatus () const;
  Presence::PresenceLevel getPresenceLevel () const;

  VcardModel *getVcardModelPtr () const {
    return m_vcard.get();
  }

  std::shared_ptr<VcardModel> m_vcard;
  std::shared_ptr<linphone::Friend> m_linphone_friend;
};

Q_DECLARE_METATYPE(ContactModel *);

#endif // CONTACT_MODEL_H_
