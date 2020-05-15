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

#include <QtDebug>

#include "components/core/CoreManager.hpp"
#include "components/sip-addresses/SipAddressesModel.hpp"
#include "utils/Utils.hpp"

#include "ConferenceAddModel.hpp"

// =============================================================================

using namespace std;

ConferenceHelperModel::ConferenceAddModel::ConferenceAddModel (QObject *parent) : QAbstractListModel(parent) {
  mConferenceHelperModel = qobject_cast<ConferenceHelperModel *>(parent);
  Q_CHECK_PTR(mConferenceHelperModel);

  CoreManager *coreManager = CoreManager::getInstance();

  QObject::connect(
    coreManager->getSipAddressesModel(), &SipAddressesModel::dataChanged,
    this, &ConferenceAddModel::handleDataChanged
  );

  for (const auto &call : coreManager->getCore()->getCalls()) {
    if (call->getCurrentParams()->getLocalConferenceMode())
    qWarning() << "Add To conference :" << Utils::coreStringToAppString(call->getRemoteAddress()->asString());
      addToConference(call->getRemoteAddress());
  }
}

int ConferenceHelperModel::ConferenceAddModel::rowCount (const QModelIndex &) const {
  return mRefs.count();
}

QHash<int, QByteArray> ConferenceHelperModel::ConferenceAddModel::roleNames () const {
  QHash<int, QByteArray> roles;
  roles[Qt::DisplayRole] = "$sipAddress";
  return roles;
}

QVariant ConferenceHelperModel::ConferenceAddModel::data (const QModelIndex &index, int role) const {
  int row = index.row();

  if (!index.isValid() || row < 0 || row >= mRefs.count())
    return QVariant();

  if (role == Qt::DisplayRole)
    return QVariant::fromValue(*mRefs[row]);

  return QVariant();
}

// -----------------------------------------------------------------------------

bool ConferenceHelperModel::ConferenceAddModel::addToConference (const shared_ptr<const linphone::Address> &linphoneAddress) {
  const QString sipAddress = Utils::coreStringToAppString(linphoneAddress->asStringUriOnly());
  if (mSipAddresses.contains(sipAddress))
    return false;

  int row = rowCount();

  beginInsertRows(QModelIndex(), row, row);
  addToConferencePrivate(linphoneAddress->clone());
  endInsertRows();

  mConferenceHelperModel->invalidate();

  return true;
}

bool ConferenceHelperModel::ConferenceAddModel::addToConference (const QString &sipAddress) {
  if (mSipAddresses.contains(sipAddress))
    return false;

  shared_ptr<linphone::Address> address = CoreManager::getInstance()->getCore()->interpretUrl(
    Utils::appStringToCoreString(sipAddress)
  );
  if (!address)
    return false;

  int row = rowCount();
  beginInsertRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Add sip address to conference: `%1`.").arg(sipAddress);
  addToConferencePrivate(address);

  endInsertRows();

  mConferenceHelperModel->invalidate();

  return true;
}

bool ConferenceHelperModel::ConferenceAddModel::removeFromConference (const QString &sipAddress) {
  auto it = mSipAddresses.find(sipAddress);
  if (it == mSipAddresses.end())
    return false;

  int row = mRefs.indexOf(&(*it));

  beginRemoveRows(QModelIndex(), row, row);

  qInfo() << QStringLiteral("Remove sip address from conference: `%1`.").arg(sipAddress);

  mRefs.removeAt(row);
  mSipAddresses.remove(sipAddress);

  endRemoveRows();

  mConferenceHelperModel->invalidate();

  return true;
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::ConferenceAddModel::update () {
  shared_ptr<linphone::Conference> conference = mConferenceHelperModel->mCore->getConference();
  if(!conference){
    qWarning() << "Create a new conference";
    conference = mConferenceHelperModel->mCore->createConferenceWithParams(mConferenceHelperModel->mCore->createConferenceParams());
  }
  // Normalement, tout ça est fait par le SDK à priori...
  auto currentCalls = CoreManager::getInstance()->getCore()->getCalls();
  list<shared_ptr<linphone::Address>> addressesToInvite, allLinphoneAddresses;	
  for (const auto &map : mRefs) {
    shared_ptr<linphone::Address> linphoneAddress = map->value("__linphoneAddress").value<shared_ptr<linphone::Address>>();
    Q_CHECK_PTR(linphoneAddress);
    const std::string sipAddress = linphoneAddress->asStringUriOnly();
    // Test if the current address is in call
    auto currentCall = currentCalls.begin();
    while( currentCall != currentCalls.end() && (*currentCall)->getRemoteAddress()->asStringUriOnly() != sipAddress)
      ++currentCall;
    if( currentCall != currentCalls.end()){// In call
      if(!(*currentCall)->getCurrentParams()->getLocalConferenceMode()){// Not in conference : add it
        qWarning() << "[TOTO] Add call to conference " << QString::fromStdString(sipAddress);
        CoreManager::getInstance()->getCore()->addToConference(*currentCall);// Else already in conference : do nothing
      }
    }else// Not in call : invite
      addressesToInvite.push_back(linphoneAddress);
    allLinphoneAddresses.push_back(linphoneAddress);
  }
  // Put in pause all call that is not in the conference list
  for(const auto &call : CoreManager::getInstance()->getCore()->getCalls()){
//    if(call->getState() != linphone::Call::State::Paused && call->getState() != linphone::Call::State::Pausing){// Need to check? what's the behaviour of calling pause twice.
      const std::string callAddress = call->getRemoteAddress()->asStringUriOnly();
      auto address = allLinphoneAddresses.begin();
      while(address != allLinphoneAddresses.end() && (*address)->asStringUriOnly() != callAddress)
        ++address;
      if(address == allLinphoneAddresses.end()){// Not in conference list : remove it from conference if it's the case and put in pause
        if( call->getCurrentParams()->getLocalConferenceMode()){
          qWarning() << "[TOTO] Remove call from conference " << QString::fromStdString(callAddress);
          CoreManager::getInstance()->getCore()->removeFromConference(call);
        }
        qWarning() << "[TOTO] Pause call : " << QString::fromStdString(callAddress);
        call->pause();
//      }
    }
  }
  qWarning() << "[TOTO] invitation : " << addressesToInvite.size() << "nouvelles addresses";
  if( addressesToInvite.size() > 0)
    conference->inviteParticipants(
      addressesToInvite,
      CoreManager::getInstance()->getCore()->createCallParams(nullptr)
    );
}


// -----------------------------------------------------------------------------

void ConferenceHelperModel::ConferenceAddModel::addToConferencePrivate (const shared_ptr<linphone::Address> &linphoneAddress) {
  QString sipAddress = Utils::coreStringToAppString(linphoneAddress->asStringUriOnly());
  QVariantMap map = CoreManager::getInstance()->getSipAddressesModel()->find(sipAddress);

  map["sipAddress"] = sipAddress;
  map["__linphoneAddress"] = QVariant::fromValue(linphoneAddress);

  mSipAddresses[sipAddress] = map;
  mRefs << &mSipAddresses[sipAddress];
}

// -----------------------------------------------------------------------------

void ConferenceHelperModel::ConferenceAddModel::handleDataChanged (
  const QModelIndex &topLeft,
  const QModelIndex &bottomRight,
  const QVector<int> &
) {
  SipAddressesModel *sipAddressesModel = CoreManager::getInstance()->getSipAddressesModel();

  int limit = bottomRight.row();
  for (int row = topLeft.row(); row <= limit; ++row) {
    const QVariantMap map = sipAddressesModel->data(sipAddressesModel->index(row, 0)).toMap();

    auto it = mSipAddresses.find(map["sipAddress"].toString());
    if (it != mSipAddresses.end()) {
      (*it)["contact"] = map.value("contact");

      int row = mRefs.indexOf(&(*it));
      Q_ASSERT(row != -1);
      emit dataChanged(index(row, 0), index(row, 0));
    }
  }
}
