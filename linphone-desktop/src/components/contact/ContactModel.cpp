/*
 * ContactModel.cpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: February 2, 2017
 *      Author: Ronan Abhamon
 */

#include <QSet>

#include "../../app/App.hpp"

#include "ContactModel.hpp"

using namespace std;

// =============================================================================

ContactModel::ContactModel (QObject *parent, shared_ptr<linphone::Friend> linphoneFriend) : QObject(parent) {
  Q_ASSERT(linphoneFriend != nullptr);

  mLinphoneFriend = linphoneFriend;

  mVcardModel = new VcardModel(linphoneFriend->getVcard());
  App::getInstance()->getEngine()->setObjectOwnership(mVcardModel, QQmlEngine::CppOwnership);

  mLinphoneFriend->setData("contact-model", *this);
}

ContactModel::ContactModel (QObject *parent, VcardModel *vcardModel) : QObject(parent) {
  Q_ASSERT(vcardModel != nullptr);

  QQmlEngine *engine = App::getInstance()->getEngine();
  if (engine->objectOwnership(vcardModel) == QQmlEngine::CppOwnership) {
    qWarning() << QStringLiteral("A contact is already linked to this vcard:") << vcardModel;
    abort();
  }

  Q_ASSERT(vcardModel->mVcard != nullptr);

  mLinphoneFriend = linphone::Friend::newFromVcard(vcardModel->mVcard);
  mLinphoneFriend->setData("contact-model", *this);

  mVcardModel = vcardModel;

  engine->setObjectOwnership(vcardModel, QQmlEngine::CppOwnership);

  qInfo() << QStringLiteral("Create contact from vcard:") << this << vcardModel;
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

void ContactModel::startEdit () {
  mLinphoneFriend->edit();
  mOldSipAddresses = mVcardModel->getSipAddresses();
}

void ContactModel::endEdit () {
  mLinphoneFriend->done();

  QVariantList sipAddresses = mVcardModel->getSipAddresses();
  QSet<QString> done;

  for (const auto &variantA : mOldSipAddresses) {
next:
    const QString &sipAddress = variantA.toString();
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

  mOldSipAddresses.clear();

  for (const auto &variant : sipAddresses) {
    const QString &sipAddress = variant.toString();
    if (done.contains(sipAddress))
      continue;
    done.insert(sipAddress);

    emit sipAddressAdded(sipAddress);
  }

  emit contactUpdated();
}

void ContactModel::abortEdit () {
  mOldSipAddresses.clear();

  emit contactUpdated();
}

// -----------------------------------------------------------------------------

Presence::PresenceStatus ContactModel::getPresenceStatus () const {
  return static_cast<Presence::PresenceStatus>(mLinphoneFriend->getConsolidatedPresence());
}

Presence::PresenceLevel ContactModel::getPresenceLevel () const {
  return Presence::getPresenceLevel(getPresenceStatus());
}

// -----------------------------------------------------------------------------

VcardModel *ContactModel::getVcardModel () const {
  return mVcardModel;
}

void ContactModel::setVcardModel (VcardModel *vcardModel) {
  Q_ASSERT(vcardModel != nullptr);
  Q_ASSERT(vcardModel != mVcardModel);

  QQmlEngine *engine = App::getInstance()->getEngine();
  engine->setObjectOwnership(vcardModel, QQmlEngine::CppOwnership);
  engine->setObjectOwnership(mVcardModel, QQmlEngine::JavaScriptOwnership);

  qInfo() << QStringLiteral("Set vcard on contact:") << this << vcardModel;
  qInfo() << QStringLiteral("Remove vcard on contact:") << this << mVcardModel;

  mLinphoneFriend->setVcard(vcardModel->mVcard);
  mVcardModel = vcardModel;
}
