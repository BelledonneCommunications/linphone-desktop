/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-desktop
 * (see https://www.linphone.org).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QQmlApplicationEngine>

#include "app/App.hpp"
#include "components/core/CoreManager.hpp"
#include "ContactModel.hpp"
#include "VcardModel.hpp"

// =============================================================================

using namespace std;

ContactModel::ContactModel (shared_ptr<linphone::Friend> linphoneFriend, QObject * parent) : QObject(parent) {
  Q_CHECK_PTR(linphoneFriend);

  mLinphoneFriend = linphoneFriend;
  mLinphoneFriend->setData("contact-model", *this);

  setVcardModelInternal(new VcardModel(linphoneFriend->getVcard()));
}

ContactModel::ContactModel (VcardModel *vcardModel, QObject * parent) : QObject(parent) {
  Q_CHECK_PTR(vcardModel);
  Q_CHECK_PTR(vcardModel->mVcard);
  Q_ASSERT(!vcardModel->mIsReadOnly);
  mLinphoneFriend = CoreManager::getInstance()->getCore()->createFriendFromVcard(vcardModel->mVcard);
  mLinphoneFriend->setData("contact-model", *this);
  if(mLinphoneFriend)
	qInfo() << QStringLiteral("Create contact from vcard:") << this << vcardModel;
  else
    qCritical() << QStringLiteral("Friend couldn't be created for vcard:") << this << vcardModel;
  setVcardModelInternal(vcardModel);
}

ContactModel::~ContactModel(){
	mVcardModel = nullptr;
	mLinphoneFriend = nullptr;
}
// -----------------------------------------------------------------------------

void ContactModel::refreshPresence () {
  Presence::PresenceStatus status = static_cast<Presence::PresenceStatus>(
    mLinphoneFriend->getConsolidatedPresence()
  );

  emit presenceStatusChanged(status);
  emit presenceLevelChanged(Presence::getPresenceLevel(status));
}

// -----------------------------------------------------------------------------

VcardModel *ContactModel::getVcardModel () const {
  return mVcardModel;
}

// -----------------------------------------------------------------------------
void ContactModel::setVcardModel (VcardModel *vcardModel) {
  VcardModel *oldVcardModel = mVcardModel;

  qInfo() << QStringLiteral("Remove vcard on contact:") << this << oldVcardModel;
  oldVcardModel->mIsReadOnly = false;
  oldVcardModel->mAvatarIsReadOnly = vcardModel->getAvatar() == oldVcardModel->getAvatar();
  oldVcardModel->deleteLater();

  qInfo() << QStringLiteral("Set vcard on contact:") << this << vcardModel;
  setVcardModelInternal(vcardModel);

  // Flush vcard.
  mLinphoneFriend->done();

  updateSipAddresses(oldVcardModel);
}

void ContactModel::setVcardModelInternal (VcardModel *vcardModel) {
  Q_CHECK_PTR(vcardModel);
  Q_ASSERT(vcardModel != mVcardModel);

  mVcardModel = vcardModel;
  mVcardModel->mAvatarIsReadOnly = false;
  mVcardModel->mIsReadOnly = true;

  App::getInstance()->getEngine()->setObjectOwnership(mVcardModel, QQmlEngine::CppOwnership);
  mVcardModel->setParent(this);

  if (mLinphoneFriend->getVcard() != vcardModel->mVcard)
    mLinphoneFriend->setVcard(vcardModel->mVcard);
}

void ContactModel::updateSipAddresses (VcardModel *oldVcardModel) {
  Q_CHECK_PTR(oldVcardModel);

  QVariantList oldSipAddresses = oldVcardModel->getSipAddresses();
  QVariantList sipAddresses = mVcardModel->getSipAddresses();
  QSet<QString> done;

  for (const auto &variantA : oldSipAddresses) {
next:
    const QString sipAddress = variantA.toString();
    if (done.contains(sipAddress))
      continue;
    done.insert(sipAddress);

    // Check if old sip address exists in new set => No changes.
    for (const auto &variantB : sipAddresses) {
      if (sipAddress == variantB.toString())
        goto next;
    }

    emit sipAddressRemoved(sipAddress);
  }

  oldSipAddresses.clear();

  for (const auto &variant : sipAddresses) {
    const QString sipAddress = variant.toString();
    if (done.contains(sipAddress))
      continue;
    done.insert(sipAddress);

    emit sipAddressAdded(sipAddress);
  }

  emit contactUpdated();
}

// -----------------------------------------------------------------------------

void ContactModel::mergeVcardModel (VcardModel *vcardModel) {
  Q_CHECK_PTR(vcardModel);

  qInfo() << QStringLiteral("Merge vcard into contact:") << this << vcardModel;

  // 1. Merge avatar.
  if (vcardModel->getAvatar().isEmpty())
    vcardModel->setAvatar(mVcardModel->getAvatar());

  // 2. Merge sip addresses, companies, emails and urls.
  for (const auto &sipAddress : mVcardModel->getSipAddresses())
    vcardModel->addSipAddress(sipAddress.toString());
  for (const auto &company : mVcardModel->getCompanies())
    vcardModel->addCompany(company.toString());
  for (const auto &email : mVcardModel->getEmails())
    vcardModel->addEmail(email.toString());
  for (const auto &url : mVcardModel->getUrls())
    vcardModel->addUrl(url.toString());

  // 3. Merge address.
  {
    const QVariantMap oldAddress = vcardModel->getAddress();
    QVariantMap newAddress = vcardModel->getAddress();

    constexpr const char *attributes[4] = { "street", "locality", "postalCode", "country" };
    bool needMerge = true;

    for (const auto &attribute : attributes)
      if (!newAddress[attribute].toString().isEmpty()) {
        needMerge = false;
        break;
      }

    if (needMerge) {
      for (const auto &attribute : attributes)
        newAddress[attribute] = oldAddress[attribute];
    }
  }

  setVcardModel(vcardModel);
}

// -----------------------------------------------------------------------------

VcardModel *ContactModel::cloneVcardModel () const {
  shared_ptr<linphone::Vcard> vcard = mVcardModel->mVcard->clone();
  Q_CHECK_PTR(vcard);
  Q_CHECK_PTR(vcard->getVcard());

  mLinphoneFriend->edit();

  VcardModel *vcardModel = new VcardModel(vcard);
  vcardModel->mIsReadOnly = false;

  qInfo() << QStringLiteral("Clone vcard from contact:") << this << vcardModel;

  return vcardModel;
}

// -----------------------------------------------------------------------------

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return static_cast<Presence::PresenceStatus>(mLinphoneFriend->getConsolidatedPresence());
}

QDateTime ContactModel::getPresenceTimestamp() const{
	if(mLinphoneFriend->getPresenceModel()){
			time_t timestamp = mLinphoneFriend->getPresenceModel()->getLatestActivityTimestamp();
			if(timestamp == -1)
				return QDateTime();
			else
				return QDateTime::fromMSecsSinceEpoch(timestamp * 1000);
	}else
		return QDateTime();
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}



bool ContactModel::hasCapability(const LinphoneEnums::FriendCapability& capability){
	return mLinphoneFriend->hasCapability(LinphoneEnums::toLinphone(capability));
}

std::shared_ptr<linphone::Friend> ContactModel::getFriend() const{
	return mLinphoneFriend;
}
