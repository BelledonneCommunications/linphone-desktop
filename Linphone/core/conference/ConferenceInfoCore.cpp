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

	connect(this, &ConferenceInfoCore::dateTimeChanged, [this] {
		setDuration(mDateTime.isValid() ? mDateTime.secsTo(mEndDateTime) / 60.0 : 60);
		setIsScheduled(mDateTime.isValid());
	});
	connect(this, &ConferenceInfoCore::endDateTimeChanged,
	        [this] { setDuration(mDateTime.isValid() ? mDateTime.secsTo(mEndDateTime) / 60.0 : 60); });
	connect(this, &ConferenceInfoCore::durationChanged, [this] {
		if (mDateTime.isValid()) setEndDateTime(mDateTime.addSecs(mDuration * 60));
	});

	if (conferenceInfo) {
		mustBeInLinphoneThread(getClassName());
		mConferenceInfoModel = Utils::makeQObject_ptr<ConferenceInfoModel>(conferenceInfo);
		mHaveModel = true;
		auto confSchedulerModel = mConferenceInfoModel->getConferenceScheduler();
		if (!confSchedulerModel) {
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			auto confScheduler = CoreModel::getInstance()->getCore()->createConferenceScheduler(defaultAccount);
			confSchedulerModel = Utils::makeQObject_ptr<ConferenceSchedulerModel>(confScheduler);
			mConferenceInfoModel->setConferenceScheduler(confSchedulerModel);
		}
		auto address = conferenceInfo->getUri();
		mUri = address && address->isValid() && !address->getDomain().empty()
		           ? Utils::coreStringToAppString(address->asStringUriOnly())
		           : "";
		mDateTime = QDateTime::fromMSecsSinceEpoch(conferenceInfo->getDateTime() * 1000);
		mDuration = conferenceInfo->getDuration();
		mEndDateTime = mDateTime.addSecs(mDuration * 60);
		mIsScheduled = mDateTime.isValid();
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
			participant["address"] = Utils::coreStringToAppString(address->asStringUriOnly());
			participant["role"] = (int)LinphoneEnums::fromLinphone(item->getRole());
			mParticipants.append(participant);
		}
		mConferenceInfoState = LinphoneEnums::fromLinphone(conferenceInfo->getState());
	} else {
		mDateTime = QDateTime::currentDateTime();
		mIsScheduled = true;
		mDuration = 60;
		mEndDateTime = mDateTime.addSecs(mDuration * 60);
		App::postModelAsync([this]() {
			auto defaultAccount = CoreModel::getInstance()->getCore()->getDefaultAccount();
			if (defaultAccount) {
				auto accountAddress = defaultAccount->getContactAddress();
				if (accountAddress) {
					auto cleanedClonedAddress = accountAddress->clone();
					cleanedClonedAddress->clean();
					auto address = Utils::coreStringToAppString(cleanedClonedAddress->asStringUriOnly());
					App::postCoreAsync([this, address]() { setOrganizerAddress(address); });
				}
			}
		});
	}
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
	mHaveModel = conferenceInfoCore.mHaveModel;
	mIsScheduled = conferenceInfoCore.mIsScheduled;
	mIsEnded = conferenceInfoCore.mIsEnded;
	mInviteEnabled = conferenceInfoCore.mInviteEnabled;
	mConferenceInfoState = conferenceInfoCore.mConferenceInfoState;
}

ConferenceInfoCore::~ConferenceInfoCore() {
	mustBeInMainThread("~" + getClassName());
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
	enableInvite(conf.inviteEnabled());
	setConferenceInfoState(conf.getConferenceInfoState());
}

void ConferenceInfoCore::setSelf(SafeSharedPointer<ConferenceInfoCore> me) {
	setSelf(me.mQDataWeak.lock());
}
void ConferenceInfoCore::setSelf(QSharedPointer<ConferenceInfoCore> me) {
	if (me) {
		if (mConferenceInfoModel) {
			mConfInfoModelConnection = nullptr;
			mConfInfoModelConnection =
			    SafeConnection<ConferenceInfoCore, ConferenceInfoModel>::create(me, mConferenceInfoModel);

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
			mConfInfoModelConnection->makeConnectToCore(&ConferenceInfoCore::lCancelConferenceInfo, [this]() {
				mConfInfoModelConnection->invokeToModel([this] {
					if (ToolModel::isMe(mOrganizerAddress)) {
						mConferenceInfoModel->cancelConference();
					}
				});
			});
			mConfInfoModelConnection->makeConnectToCore(&ConferenceInfoCore::lDeleteConferenceInfo, [this]() {
				mConfInfoModelConnection->invokeToModel([this] { mConferenceInfoModel->deleteConferenceInfo(); });
			});
			mConfInfoModelConnection->makeConnectToModel(&ConferenceInfoModel::conferenceInfoDeleted, [this] {
				mConfInfoModelConnection->invokeToCore([this] { removed(this); });
			});

			mConfInfoModelConnection->makeConnectToModel(
			    &ConferenceInfoModel::schedulerStateChanged, [this](linphone::ConferenceScheduler::State state) {
				    auto confInfoState = mConferenceInfoModel->getState();
				    QString uri;
				    if (state == linphone::ConferenceScheduler::State::Ready) {
					    uri = mConferenceInfoModel->getConferenceScheduler()->getUri();
				    }
				    mConfInfoModelConnection->invokeToCore([this, state = LinphoneEnums::fromLinphone(state),
				                                            infoState = LinphoneEnums::fromLinphone(confInfoState),
				                                            uri] {
					    setConferenceSchedulerState(state);
					    setConferenceInfoState(infoState);
					    if (state == LinphoneEnums::ConferenceSchedulerState::Ready) {
						    setUri(uri);
						    mConfInfoModelConnection->invokeToModel([this, uri, infoState] {
							    if (infoState == LinphoneEnums::ConferenceInfoState::New)
								    emit CoreModel::getInstance()->conferenceInfoCreated(
								        mConferenceInfoModel->getConferenceInfo());
						    });
					    }
					    setConferenceSchedulerState(state);
				    });
			    });
			mConfInfoModelConnection->makeConnectToModel(
			    &ConferenceInfoModel::infoStateChanged, [this](linphone::ConferenceInfo::State state) {
				    auto uri = mConferenceInfoModel->getConferenceScheduler()->getUri();
				    mConfInfoModelConnection->invokeToCore([this, infoState = LinphoneEnums::fromLinphone(state), uri] {
					    setConferenceInfoState(infoState);
				    });
			    });
			mConfInfoModelConnection->makeConnectToModel(
			    &ConferenceInfoModel::invitationsSent,
			    [this](const std::list<std::shared_ptr<linphone::Address>> &failedInvitations) {});

		} else { // Create
			mCoreModelConnection = SafeConnection<ConferenceInfoCore, CoreModel>::create(me, CoreModel::getInstance());
		}
	}
}

QString ConferenceInfoCore::getStartEndDateString() {
	if (Utils::datesAreEqual(mDateTime.date(), mEndDateTime.date())) {
		return QLocale().toString(mDateTime, "ddd d MMM - hh") + "h - " + QLocale().toString(mEndDateTime, "hh") + "h";
	} else {
		return QLocale().toString(mDateTime, "ddd d MMM - hh") + "h - " +
		       QLocale().toString(mEndDateTime, "ddd d MMM - hh") + "h";
	}
}

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

bool ConferenceInfoCore::getHaveModel() const {
	return mHaveModel;
}

void ConferenceInfoCore::setHaveModel(const bool &haveModel) {
	if (mHaveModel != haveModel) {
		mHaveModel = haveModel;
		emit haveModelChanged();
	}
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

bool ConferenceInfoCore::inviteEnabled() const {
	return mInviteEnabled;
}

QVariantList ConferenceInfoCore::getParticipants() const {
	return mParticipants;
}

int ConferenceInfoCore::getParticipantCount() const {
	return mParticipants.size();
}

void ConferenceInfoCore::addParticipant(const QString &address) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	for (auto &participant : mParticipants) {
		auto map = participant.toMap();
		if (map["address"].toString() == address) return;
	}
	QVariantMap participant;
	participant["address"] = address;
	participant["role"] = (int)LinphoneEnums::ParticipantRole::Listener;
	mParticipants.append(participant);
	emit participantsChanged();
}

void ConferenceInfoCore::addParticipants(const QStringList &addresses) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	bool addressAdded = false;
	for (auto &address : addresses) {
		auto found = std::find_if(mParticipants.begin(), mParticipants.end(), [address](QVariant participant) {
			return participant.toMap()["address"].toString() == address;
		});
		if (found == mParticipants.end()) {
			QVariantMap participant;
			participant["address"] = address;
			participant["role"] = (int)LinphoneEnums::ParticipantRole::Listener;
			mParticipants.append(participant);
			addressAdded = true;
		}
	}
	if (addressAdded) emit participantsChanged();
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
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	mParticipants.clear();
	for (auto &address : adresses) {
		QVariantMap participant;
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

void ConferenceInfoCore::setIsScheduled(const bool &on) {
	if (mIsScheduled != on) {
		mIsScheduled = on;
		emit isScheduledChanged();
	}
}

void ConferenceInfoCore::setIsEnded(bool ended) {
	if (mIsEnded != ended) {
		mIsEnded = ended;
		emit isEndedChanged();
	}
}

void ConferenceInfoCore::enableInvite(const bool &enable) {
	if (enable != mInviteEnabled) {
		mInviteEnabled = enable;
		emit inviteEnabledChanged();
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
	mDateTime = model->getDateTime();
	mDuration = model->getDuration();
	mSubject = model->getSubject();
	mOrganizerName = model->getOrganizerName();
	mOrganizerAddress = model->getOrganizerAddress();
	mDescription = model->getDescription();
	mParticipants.clear();
	for (auto &infos : model->getParticipantInfos()) {
		auto address = Utils::coreStringToAppString(infos->getAddress()->asStringUriOnly());
		QVariantMap participant;
		participant["address"] = address;
		participant["role"] = (int)LinphoneEnums::ParticipantRole::Listener;
		mParticipants.append(participant);
	}
}

void ConferenceInfoCore::writeIntoModel(std::shared_ptr<ConferenceInfoModel> model) {
	mustBeInLinphoneThread(getClassName() + "::writeIntoModel()");
	model->setDateTime(mIsScheduled ? mDateTime : QDateTime());
	model->setDuration(mDuration);
	model->setSubject(mSubject);
	model->enableInvite(mInviteEnabled);
	if (!mOrganizerAddress.isEmpty()) {
		model->setOrganizer(mOrganizerAddress);
		lDebug() << log().arg("Use of %1").arg(mOrganizerAddress);
	} else lDebug() << log().arg("Use of %1").arg(model->getOrganizerAddress());

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
	if (mConferenceInfoModel && mConferenceInfoModel->getConferenceScheduler()) {
		mConfInfoModelConnection->invokeToModel([this, thisCopy]() { // Copy values to avoid concurrency
			mustBeInLinphoneThread(getClassName() + "::save()");
			thisCopy->writeIntoModel(mConferenceInfoModel);
			thisCopy->deleteLater();
			mConferenceInfoModel->updateConferenceInfo();
			mConfInfoModelConnection->invokeToCore([this] {
				undo(); // Reset new values because some values can be invalid and not changed.
				emit dataSaved();
			});
		});
	} else {
		mCoreModelConnection->invokeToModel([this, thisCopy]() {
			if (CoreModel::getInstance()->getCore()->getDefaultAccount()->getState() !=
			    linphone::RegistrationState::Ok) {
				//: "Erreur"
				Utils::showInformationPopup(tr("information_popup_error_title"),
											//: "Votre compte est déconnecté"
											tr("information_popup_disconnected_account_message"), false);
				emit saveFailed();
				return;
			}
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
				} else lCritical() << "No contact address";
			} else lCritical() << "No default account";
			// Add text capability for chat in conf
			linphoneConf->setCapability(linphone::StreamType::Text, true);
			auto confInfoModel = Utils::makeQObject_ptr<ConferenceInfoModel>(linphoneConf);
			auto confSchedulerModel = confInfoModel->getConferenceScheduler();
			if (!confSchedulerModel) {
				auto confScheduler = CoreModel::getInstance()->getCore()->createConferenceScheduler(defaultAccount);
				confSchedulerModel = Utils::makeQObject_ptr<ConferenceSchedulerModel>(confScheduler);
				confInfoModel->setConferenceScheduler(confSchedulerModel);
			}
			mCoreModelConnection->invokeToCore([this, thisCopy, confSchedulerModel, linphoneConf, confInfoModel]() {
				setHaveModel(true);
				mConferenceInfoModel = confInfoModel;
				mCoreModelConnection->invokeToModel([this, thisCopy, confSchedulerModel, linphoneConf]() {
					thisCopy->writeIntoModel(mConferenceInfoModel);
					thisCopy->deleteLater();
					confSchedulerModel->setInfo(linphoneConf);
					mCoreModelConnection->invokeToCore([this]() {
						setSelf(mCoreModelConnection->mCore);
						emit dataSaved();
					});
				});
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
			mConfInfoModelConnection->invokeToCore([this, conf]() {
				this->reset(*conf);
				conf->deleteLater();
			});
		});
	}
}

void ConferenceInfoCore::cancelCreation() {
	if (mConferenceInfoModel) {
		mConferenceInfoModel->setConferenceScheduler(nullptr);
	}
}

//-------------------------------------------------------------------------------------------------

void ConferenceInfoCore::onInvitationsSent(const std::list<std::shared_ptr<linphone::Address>> &failedInvitations) {
	lDebug() << "ConferenceInfoCore::onInvitationsSent";
	emit invitationsSent();
}

bool ConferenceInfoCore::isAllDayConf() const {
	return mDateTime.time().hour() == 0 && mDateTime.time().minute() == 0 && mEndDateTime.time().hour() == 23 &&
	       mEndDateTime.time().minute() == 59;
}
