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
    auto parameters = mConferenceHelperModel->mCore->createConferenceParams();
    parameters->setVideoEnabled(false);// Video is not yet fully supported by the application in conference
    conference = mConferenceHelperModel->mCore->createConferenceWithParams(parameters);
  }
  auto currentCalls = CoreManager::getInstance()->getCore()->getCalls();
  list<shared_ptr<linphone::Address>> allLinphoneAddresses;

//1) Invite participants first to avoid removing conference if empty
  for (const auto &map : mRefs) {
    shared_ptr<linphone::Address> linphoneAddress = map->value("__linphoneAddress").value<shared_ptr<linphone::Address>>();
    Q_CHECK_PTR(linphoneAddress);
    allLinphoneAddresses.push_back(linphoneAddress);
  }
  if( allLinphoneAddresses.size() > 0){
    auto parameters = CoreManager::getInstance()->getCore()->createCallParams(nullptr);
    parameters->enableVideo(false);
    conference->inviteParticipants(
      allLinphoneAddresses,
      parameters
    );
  }
// 2) Put in pause and remove all calls that are not in the conference list
  for(const auto &call : CoreManager::getInstance()->getCore()->getCalls()){
      const std::string callAddress = call->getRemoteAddress()->asStringUriOnly();
      auto address = allLinphoneAddresses.begin();
      while(address != allLinphoneAddresses.end() && (*address)->asStringUriOnly() != callAddress)
        ++address;
      if(address == allLinphoneAddresses.end()){// Not in conference list :  put in pause and remove it from conference if it's the case
        if( call->getParams()->getLocalConferenceMode() ){// Remove conference if it is not yet requested
          CoreManager::getInstance()->getCore()->removeFromConference(call);
        }else
          call->pause();
      }
    }
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
