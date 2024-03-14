/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#include "ConferenceInfoCore.hpp"

#include "core/App.hpp"
#include "core/proxy/ListProxy.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include "tool/Utils.hpp"
#include "tool/thread/SafeConnection.hpp"

DEFINE_ABSTRACT_OBJECT(ConferenceInfoCore)

QSharedPointer<ConferenceInfoCore>
ConferenceInfoCore::create(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo) {
	auto sharedPointer =
	    QSharedPointer<ConferenceInfoCore>(new ConferenceInfoCore(conferenceInfo), &QObject::deleteLater);
	sharedPointer->setSelf(sharedPointer);
	if (isInLinphoneThread()) sharedPointer->moveToThread(App::getInstance()->thread());
	return sharedPointer;
}

ConferenceInfoCore::ConferenceInfoCore(std::shared_ptr<linphone::ConferenceInfo> conferenceInfo, QObject *parent)
    : QObject(parent) {
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
	mTimeZoneModel = QSharedPointer<TimeZoneModel>(new TimeZoneModel(
	    QTimeZone::systemTimeZone())); // Always return system timezone because this info is not stored in database.

	if (conferenceInfo) {
		mustBeInLinphoneThread(getClassName());
		mConferenceInfoModel = Utils::makeQObject_ptr<ConferenceInfoModel>(conferenceInfo);
		auto confSchedulerModel = mConferenceInfoModel->getConferenceScheduler();
		if (!confSchedulerModel) {
			auto confScheduler = CoreModel::getInstance()->getCore()->createConferenceScheduler();
			confSchedulerModel = Utils::makeQObject_ptr<ConferenceSchedulerModel>(confScheduler);
			mConferenceInfoModel->setConferenceScheduler(confSchedulerModel);
		}
		auto address = conferenceInfo->getUri();
		mUri = address && address->isValid() && !address->getDomain().empty()
		           ? Utils::coreStringToAppString(address->asStringUriOnly())
		           : "";
		mDateTime = QDateTime::fromMSecsSinceEpoch(conferenceInfo->getDateTime() * 1000, Qt::LocalTime);
		mDuration = conferenceInfo->getDuration();
		mEndDateTime = mDateTime.addSecs(mDuration * 60);
		mOrganizerAddress = Utils::coreStringToAppString(conferenceInfo->getOrganizer()->asStringUriOnly());
		mOrganizerName = Utils::coreStringToAppString(conferenceInfo->getOrganizer()->getDisplayName());
		if (mOrganizerName.isEmpty()) {
			mOrganizerName = Utils::coreStringToAppString(conferenceInfo->getOrganizer()->getUsername());
			mOrganizerName.replace(".", " ");
		}
		mSubject = Utils::coreStringToAppString(conferenceInfo->getSubject());
		mDescription = Utils::coreStringToAppString(conferenceInfo->getDescription());
		mIsEnded = getDateTimeUtc().addSecs(mDuration * 60) < QDateTime::currentDateTimeUtc();

		for (auto item : conferenceInfo->getParticipantInfos()) {
			QVariantMap participant;
			auto address = item->getAddress();
			auto name = Utils::coreStringToAppString(address->getDisplayName());
			if (name.isEmpty()) {
				name = Utils::coreStringToAppString(address->getUsername());
				name.replace(".", " ");
			}
			participant["displayName"] = name;
			participant["address"] = Utils::coreStringToAppString(address->asStringUriOnly());
			participant["role"] = (int)LinphoneEnums::fromLinphone(item->getRole());
			mParticipants.append(participant);
		}
		mConferenceInfoState = LinphoneEnums::fromLinphone(conferenceInfo->getState());
	} else {
		mDateTime = QDateTime::currentDateTime();
		mEndDateTime = QDateTime::currentDateTime().addSecs(3600);
		App::postModelSync([this]() {
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (defaultAccount) {
				auto accountAddress = defaultAccount->getContactAddress();
				if (accountAddress) {
					auto cleanedClonedAddress = accountAddress->clone();
					cleanedClonedAddress->clean();
					mOrganizerAddress = Utils::coreStringToAppString(cleanedClonedAddress->asStringUriOnly());
					qDebug() << "set organizer address" << mOrganizerAddress;
				}
			}
		});
	}

	connect(this, &ConferenceInfoCore::endDateTimeChanged,
	        [this] { setDuration(mDateTime.secsTo(mEndDateTime) / 60.0); });
	connect(this, &ConferenceInfoCore::durationChanged, [this] { setEndDateTime(mDateTime.addSecs(mDuration * 60)); });
}

ConferenceInfoCore::ConferenceInfoCore(const ConferenceInfoCore &conferenceInfoCore) {
	mDateTime = conferenceInfoCore.mDateTime;
	mEndDateTime = conferenceInfoCore.mEndDateTime;
	mDuration = conferenceInfoCore.mDuration;
	mOrganizerAddress = conferenceInfoCore.mOrganizerAddress;
	mOrganizerName = conferenceInfoCore.mOrganizerName;
	mSubject = conferenceInfoCore.mSubject;
	mDescription = conferenceInfoCore.mDescription;
	mUri = conferenceInfoCore.mUri;
	mParticipants = conferenceInfoCore.mParticipants;
	mTimeZoneModel = conferenceInfoCore.mTimeZoneModel;
	mIsScheduled = conferenceInfoCore.mIsScheduled;
	mIsEnded = conferenceInfoCore.mIsEnded;
	mInviteMode = conferenceInfoCore.mInviteMode;
	mConferenceInfoState = conferenceInfoCore.mConferenceInfoState;
}

ConferenceInfoCore::~ConferenceInfoCore() {
	mustBeInMainThread("~" + getClassName());
	mCheckEndTimer.stop();
}

void ConferenceInfoCore::reset(const ConferenceInfoCore &conf) {
	setDateTime(conf.getDateTimeSystem());
	setDuration(conf.getDuration());
	setOrganizerAddress(conf.getOrganizerAddress());
	setOrganizerName(conf.getOrganizerName());
	setSubject(conf.getSubject());
	setDescription(conf.getDescription());
	setUri(conf.getUri());
	resetParticipants(conf.getParticipants());
	setTimeZoneModel(conf.getTimeZoneModel());
	setIsScheduled(conf.isScheduled());
	setIsEnded(conf.isEnded());
	setInviteMode(conf.getInviteMode());
	setConferenceInfoState(conf.getConferenceInfoState());
}

void ConferenceInfoCore::setSelf(SafeSharedPointer<ConferenceInfoCore> me) {
	setSelf(me.mQDataWeak.lock());
}
void ConferenceInfoCore::setSelf(QSharedPointer<ConferenceInfoCore> me) {
	if (me) {
		if (mConferenceInfoModel) {
			mConfInfoModelConnection = nullptr;
			mConfInfoModelConnection = QSharedPointer<SafeConnection<ConferenceInfoCore, ConferenceInfoModel>>(
			    new SafeConnection<ConferenceInfoCore, ConferenceInfoModel>(me, mConferenceInfoModel),
			    &QObject::deleteLater);

			mConfInfoModelConnection->makeConnectToModel(&ConferenceInfoModel::dateTimeChanged,
			                                             [this](const QDateTime &date) {
				                                             mConfInfoModelConnection->invokeToCore([this, date] {
					                                             setDateTime(date);
					                                             setIsEnded(computeIsEnded());
				                                             });
			                                             });
			mConfInfoModelConnection->makeConnectToModel(&ConferenceInfoModel::durationChanged, [this](int duration) {
				mConfInfoModelConnection->invokeToCore([this, duration] {
					setDuration(duration);
					setIsEnded(computeIsEnded());
				});
			});
			mConfInfoModelConnection->makeConnectToCore(&ConferenceInfoCore::lDeleteConferenceInfo,
			                                            [this]() { mConferenceInfoModel->deleteConferenceInfo(); });
			mConfInfoModelConnection->makeConnectToModel(&ConferenceInfoModel::conferenceInfoDeleted,
			                                             &ConferenceInfoCore::removed);

			mConfInfoModelConnection->makeConnectToModel(
			    &ConferenceInfoModel::schedulerStateChanged, [this](linphone::ConferenceScheduler::State state) {
				    mConfInfoModelConnection->invokeToCore(
				        [this, state = LinphoneEnums::fromLinphone(state)] { setConferenceSchedulerState(state); });
			    });
			mConfInfoModelConnection->makeConnectToModel(
			    &ConferenceInfoModel::invitationsSent,
			    [this](const std::list<std::shared_ptr<linphone::Address>> &failedInvitations) {
				    qDebug() << "invitations sent";
			    });
		} else { // Create
			mCoreModelConnection = QSharedPointer<SafeConnection<ConferenceInfoCore, CoreModel>>(
			    new SafeConnection<ConferenceInfoCore, CoreModel>(me, CoreModel::getInstance()), &QObject::deleteLater);
		}
	}
}

//------------------------------------------------------------------------------------------------

// Note conferenceInfo->getDateTime uses UTC
QDateTime ConferenceInfoCore::getDateTimeUtc() const {
	return getDateTimeSystem().toUTC();
}

QDateTime ConferenceInfoCore::getDateTimeSystem() const {
	return mDateTime;
}

int ConferenceInfoCore::getDuration() const {
	return mDuration;
}

QDateTime ConferenceInfoCore::getEndDateTime() const {
	return mDateTime.addSecs(mDuration * 60);
}

QDateTime ConferenceInfoCore::getEndDateTimeUtc() const {
	return getEndDateTime().toUTC();
}

QString ConferenceInfoCore::getOrganizerName() const {
	return mOrganizerName;
}

QString ConferenceInfoCore::getOrganizerAddress() const {
	return mOrganizerAddress;
}

QString ConferenceInfoCore::getSubject() const {
	return mSubject;
}

QString ConferenceInfoCore::getDescription() const {
	return mDescription;
}

void ConferenceInfoCore::setDateTime(const QDateTime &date) {
	if (date != mDateTime) {
		mDateTime = date;
		emit dateTimeChanged();
	}
}

void ConferenceInfoCore::setEndDateTime(const QDateTime &date) {
	if (date != mEndDateTime) {
		mEndDateTime = date;
		emit endDateTimeChanged();
	}
}

void ConferenceInfoCore::setDuration(int duration) {
	if (duration != mDuration) {
		mDuration = duration;
		emit durationChanged();
	}
}

void ConferenceInfoCore::setSubject(const QString &subject) {
	if (subject != mSubject) {
		mSubject = subject;
		emit subjectChanged();
	}
}

void ConferenceInfoCore::setOrganizerName(const QString &organizer) {
	if (organizer != mOrganizerName) {
		mOrganizerName = organizer;
		emit organizerNameChanged();
	}
}

void ConferenceInfoCore::setOrganizerAddress(const QString &organizer) {
	if (organizer != mOrganizerAddress) {
		mOrganizerAddress = organizer;
		emit organizerAddressChanged();
	}
}

void ConferenceInfoCore::setUri(const QString &uri) {
	if (uri != mUri) {
		mUri = uri;
		emit uriChanged();
	}
}

void ConferenceInfoCore::setTimeZoneModel(TimeZoneModel *model) {
	if (mTimeZoneModel->getDisplayName() != model->getDisplayName() ||
	    mTimeZoneModel->getCountryName() != model->getCountryName() ||
	    mTimeZoneModel->getOffsetFromUtc() != model->getOffsetFromUtc() ||
	    mTimeZoneModel->getStandardTimeOffset() != model->getStandardTimeOffset() ||
	    mTimeZoneModel->getTimeZone() != model->getTimeZone()) {

		mTimeZoneModel = QSharedPointer<TimeZoneModel>(model);
		emit timeZoneModelChanged();
	}
}

void ConferenceInfoCore::setDescription(const QString &description) {
	if (description != mDescription) {
		mDescription = description;
		emit descriptionChanged();
	}
}

QString ConferenceInfoCore::getUri() const {
	return mUri;
}

bool ConferenceInfoCore::isScheduled() const {
	return mIsScheduled;
}

bool ConferenceInfoCore::computeIsEnded() const {
	return getEndDateTimeUtc() < QDateTime::currentDateTimeUtc();
}

bool ConferenceInfoCore::isEnded() const {
	return mIsEnded;
}

int ConferenceInfoCore::getInviteMode() const {
	return mInviteMode;
}

QVariantList ConferenceInfoCore::getParticipants() const {
	return mParticipants;
}

int ConferenceInfoCore::getParticipantCount() const {
	return mParticipants.size();
}

void ConferenceInfoCore::addParticipant(const QString &address) {
	for (auto &participant : mParticipants) {
		auto map = participant.toMap();
		if (map["address"].toString() == address) return;
	}
	QVariantMap participant;
	auto displayNameObj = Utils::getDisplayName(address);
	participant["displayName"] = displayNameObj ? displayNameObj->getValue() : "";
	participant["address"] = address;
	participant["role"] = (int)LinphoneEnums::ParticipantRole::Listener;
	mParticipants.append(participant);
	emit participantsChanged();
}

void ConferenceInfoCore::removeParticipant(const QString &address) {
	for (int i = 0; i < mParticipants.size(); ++i) {
		auto map = mParticipants[i].toMap();
		if (map["address"].toString() == address) {
			mParticipants.remove(i);
			emit participantsChanged();
			return;
		}
	}
}

void ConferenceInfoCore::removeParticipant(const int &index) {
	mParticipants.remove(index);
	emit participantsChanged();
}

QString ConferenceInfoCore::getParticipantAddressAt(const int &index) {
	if (index < 0 || index >= mParticipants.size()) return QString();
	auto map = mParticipants[index].toMap();
	return map["address"].toString();
}

void ConferenceInfoCore::clearParticipants() {
	mParticipants.clear();
	emit participantsChanged();
}

void ConferenceInfoCore::resetParticipants(QVariantList participants) {
	mParticipants = participants;
}

void ConferenceInfoCore::resetParticipants(const QStringList &adresses) {
	mParticipants.clear();
	for (auto &address : adresses) {
		QVariantMap participant;
		QString name;
		auto nameObj = Utils::getDisplayName(address);
		if (nameObj) name = nameObj->getValue().toString();
		participant["displayName"] = name;
		participant["address"] = address;
		participant["role"] = (int)LinphoneEnums::ParticipantRole::Listener;
		mParticipants.append(participant);
	}
	emit participantsChanged();
}

int ConferenceInfoCore::getParticipantIndex(const QString &address) {
	for (int i = 0; i < mParticipants.count(); ++i) {
		auto map = mParticipants[i].toMap();
		if (map["address"].toString() == address) {
			return i;
		}
	}
	return -1;
}

TimeZoneModel *ConferenceInfoCore::getTimeZoneModel() const {
	return mTimeZoneModel.get();
}

// QString ConferenceInfoCore::getIcalendarString() const {
// 	return Utils::coreStringToAppString(mConferenceInfoModel->getIcalendarString());
// }

LinphoneEnums::ConferenceInfoState ConferenceInfoCore::getConferenceInfoState() const {
	return mConferenceInfoState;
}

LinphoneEnums::ConferenceSchedulerState ConferenceInfoCore::getConferenceSchedulerState() const {
	return mConferenceSchedulerState;
}

//------------------------------------------------------------------------------------------------
// Datetime is in Custom (Locale/UTC/System). Convert into UTC for conference info

void ConferenceInfoCore::setIsScheduled(const bool &on) {
	if (mIsScheduled != on) {
		mIsScheduled = on;
		emit isScheduledChanged();
	}
}

void ConferenceInfoCore::setIsEnded(bool ended) {
	if (mIsEnded != ended) {
		mIsEnded = ended;
		if (mIsEnded) mCheckEndTimer.stop(); // No need to run the timer.
		else mCheckEndTimer.start();
		emit isEndedChanged();
	}
}

void ConferenceInfoCore::setInviteMode(const int &mode) {
	if (mode != mInviteMode) {
		mInviteMode = mode;
		emit inviteModeChanged();
	}
}

void ConferenceInfoCore::setConferenceInfoState(LinphoneEnums::ConferenceInfoState state) {
	if (state != mConferenceInfoState) {
		mConferenceInfoState = state;
		emit conferenceInfoStateChanged();
	}
}

void ConferenceInfoCore::setConferenceSchedulerState(LinphoneEnums::ConferenceSchedulerState state) {
	if (state != mConferenceSchedulerState) {
		mConferenceSchedulerState = state;
		emit conferenceSchedulerStateChanged();
	}
}

void ConferenceInfoCore::writeFromModel(const std::shared_ptr<ConferenceInfoModel> &model) {
	mustBeInLinphoneThread(getClassName() + "::writeFromModel()");
	setDateTime(model->getDateTime());
	setDuration(model->getDuration());
	setSubject(model->getSubject());
	setOrganizerName(model->getOrganizerName());
	setOrganizerAddress(model->getOrganizerAddress());
	setDescription(model->getDescription());
	QStringList participantAddresses;
	for (auto &infos : model->getParticipantInfos()) {
		participantAddresses.append(Utils::coreStringToAppString(infos->getAddress()->asStringUriOnly()));
	}
	resetParticipants(participantAddresses);
}

void ConferenceInfoCore::writeIntoModel(std::shared_ptr<ConferenceInfoModel> model) {
	mustBeInLinphoneThread(getClassName() + "::writeIntoModel()");
	model->setDateTime(mDateTime);
	model->setDuration(mDuration);
	model->setSubject(mSubject);
	model->setOrganizer(mOrganizerAddress);
	model->setDescription(mDescription);
	std::list<std::shared_ptr<linphone::ParticipantInfo>> participantInfos;
	for (auto &p : mParticipants) {
		auto map = p.toMap();
		auto address = map["address"].toString();
		auto linAddr = ToolModel::interpretUrl(address);
		auto infos = linphone::Factory::get()->createParticipantInfo(linAddr);
		participantInfos.push_back(infos);
	}
	model->setParticipantInfos(participantInfos);
}

void ConferenceInfoCore::save() {
	mustBeInMainThread(getClassName() + "::save()");
	ConferenceInfoCore *thisCopy = new ConferenceInfoCore(*this); // Pointer to avoid multiple copies in lambdas
	if (mConferenceInfoModel) {
		mConfInfoModelConnection->invokeToModel([this, thisCopy]() { // Copy values to avoid concurrency
			mustBeInLinphoneThread(getClassName() + "::save()");
			thisCopy->writeIntoModel(mConferenceInfoModel);
			thisCopy->deleteLater();
		});
	} else {
		mCoreModelConnection->invokeToModel([this, thisCopy]() {
			auto linphoneConf =
			    CoreModel::getInstance()->getCore()->findConferenceInformationFromUri(ToolModel::interpretUrl(mUri));

			if (linphoneConf == nullptr) {
				linphoneConf = linphone::Factory::get()->createConferenceInfo();
			}
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (defaultAccount) {
				auto accountAddress = defaultAccount->getContactAddress();
				if (accountAddress) {
					auto cleanedClonedAddress = accountAddress->clone();
					cleanedClonedAddress->clean();
					if (!linphoneConf->getOrganizer()) linphoneConf->setOrganizer(cleanedClonedAddress);
					if (mOrganizerAddress.isEmpty())
						mOrganizerAddress = Utils::coreStringToAppString(accountAddress->asStringUriOnly());
				}
			}
			mConferenceInfoModel = Utils::makeQObject_ptr<ConferenceInfoModel>(linphoneConf);
			// mConferenceInfoModel->createConferenceScheduler();
			auto confSchedulerModel = mConferenceInfoModel->getConferenceScheduler();
			if (!confSchedulerModel) {
				auto confScheduler = CoreModel::getInstance()->getCore()->createConferenceScheduler();
				confSchedulerModel = Utils::makeQObject_ptr<ConferenceSchedulerModel>(confScheduler);
				mConferenceInfoModel->setConferenceScheduler(confSchedulerModel);
			}
			thisCopy->writeIntoModel(mConferenceInfoModel);
			thisCopy->deleteLater();
			mCoreModelConnection->invokeToCore([this, confSchedulerModel, linphoneConf]() {
				setSelf(mCoreModelConnection->mCore);
				mCoreModelConnection->invokeToModel(
				    [this, confSchedulerModel, linphoneConf]() { confSchedulerModel->setInfo(linphoneConf); });
			});
		});
	}
}

void ConferenceInfoCore::undo() {
	if (mConferenceInfoModel) {
		mConfInfoModelConnection->invokeToModel([this]() {
			ConferenceInfoCore *conf = new ConferenceInfoCore(*this);
			conf->writeFromModel(mConferenceInfoModel);
			conf->moveToThread(App::getInstance()->thread());
			mConfInfoModelConnection->invokeToCore([this, conf]() mutable {
				this->reset(*conf);
				conf->deleteLater();
			});
		});
	}
}

void ConferenceInfoCore::cancelConference() {
	if (!mConferenceInfoModel) return;
	mConferenceInfoModel->cancelConference();
}

//-------------------------------------------------------------------------------------------------

// void ConferenceInfoCore::createConference(const int &securityLevel) {
// 	CoreModel::getInstance()->getTimelineListModel()->mAutoSelectAfterCreation = false;
// 	shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();
// 	static std::shared_ptr<linphone::Conference> conference;
// 	qInfo() << "Conference creation of " << getSubject() << " at " << securityLevel << " security, organized by "
// 	        << getOrganizer() << " for " << getDateTimeSystem().toString();
// 	qInfo() << "Participants:";
// 	for (auto p : mConferenceInfoModel->getParticipants())
// 		qInfo() << "\t" << p->asString().c_str();

// 	mConferenceScheduler = ConferenceScheduler::create();
// 	mConferenceScheduler->mSendInvite = mInviteMode;
// 	connect(mConferenceScheduler.get(), &ConferenceScheduler::invitationsSent, this,
// 	        &ConferenceInfoCore::onInvitationsSent);
// 	connect(mConferenceScheduler.get(), &ConferenceScheduler::stateChanged, this,
// 	        &ConferenceInfoCore::onConferenceSchedulerStateChanged);
// 	mConferenceScheduler->getConferenceScheduler()->setInfo(mConferenceInfoModel);
// }

//-------------------------------------------------------------------------------------------------

// void ConferenceInfoCore::onConferenceSchedulerStateChanged(linphone::ConferenceScheduler::State state) {
// 	qDebug() << "ConferenceInfoCore::onConferenceSchedulerStateChanged: " << (int)state;
// 	mLastConferenceSchedulerState = state;
// 	if (state == linphone::ConferenceScheduler::State::Ready) emit conferenceCreated();
// 	else if (state == linphone::ConferenceScheduler::State::Error) emit conferenceCreationFailed();
// 	emit conferenceInfoChanged();
// }
void ConferenceInfoCore::onInvitationsSent(const std::list<std::shared_ptr<linphone::Address>> &failedInvitations) {
	qDebug() << "ConferenceInfoCore::onInvitationsSent";
	emit invitationsSent();
}

bool ConferenceInfoCore::isAllDayConf() const {
	return mDateTime.time().hour() == 0 && mDateTime.time().minute() == 0 && mEndDateTime.time().hour() == 23 &&
	       mEndDateTime.time().minute() == 59;
}