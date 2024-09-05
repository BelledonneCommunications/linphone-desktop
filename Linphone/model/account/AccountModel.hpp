/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef ACCOUNT_MODEL_H_
#define ACCOUNT_MODEL_H_

#include "model/listener/Listener.hpp"
#include "tool/AbstractObject.hpp"

#include <QObject>
#include <linphone++/linphone.hh>

struct AccountUserData;

class AccountModel : public ::Listener<linphone::Account, linphone::AccountListener>,
                     public linphone::AccountListener,
                     public AbstractObject {
	Q_OBJECT
public:
	AccountModel(const std::shared_ptr<linphone::Account> &account, QObject *parent = nullptr);
	~AccountModel();

	virtual void onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
	                                        linphone::RegistrationState state,
	                                        const std::string &message) override;
	virtual void
	onMessageWaitingIndicationChanged(const std::shared_ptr<linphone::Account> &account,
	                                  const std::shared_ptr<const linphone::MessageWaitingIndication> &mwi) override;

	void onDefaultAccountChanged();

	std::string getConfigAccountUiSection();

	void setPictureUri(QString uri);
	void setDefault();
	void removeAccount();
	void resetMissedCallsCount();
	void refreshUnreadNotifications();
	int getMissedCallsCount() const;
	int getUnreadMessagesCount() const;
	void setDisplayName(QString displayName);
	void setDialPlan(int index);
	void setRegisterEnabled(bool enabled);
	bool getNotificationsAllowed();
	void setNotificationsAllowed(bool value);
	void setMwiServerAddress(QString value);
	void setTransport(linphone::TransportType value);
	void setServerAddress(QString value);
	void setOutboundProxyEnabled(bool value);
	void setStunServer(QString value);
	void setIceEnabled(bool value);
	void setAvpfEnabled(bool value);
	void setBundleModeEnabled(bool value);
	void setExpire(int value);
	void setConferenceFactoryAddress(QString value);
	void setAudioVideoConferenceFactoryAddress(QString value);
	void setLimeServerUrl(QString value);
	QString dialPlanAsString(const std::shared_ptr<linphone::DialPlan> &dialPlan);
	int getVoicemailCount();

signals:
	void registrationStateChanged(const std::shared_ptr<linphone::Account> &account,
	                              linphone::RegistrationState state,
	                              const std::string &message);
	void defaultAccountChanged(bool isDefault);

	void pictureUriChanged(QString uri);
	void unreadNotificationsChanged(int unreadMessagesCount, int unreadCallsCount);
	void displayNameChanged(QString displayName);
	void dialPlanChanged(int index);
	void registerEnabledChanged(bool enabled);
	void notificationsAllowedChanged(bool value);
	void mwiServerAddressChanged(QString value);
	void transportChanged(linphone::TransportType value);
	void serverAddressChanged(QString value);
	void outboundProxyEnabledChanged(bool value);
	void stunServerChanged(QString value);
	void iceEnabledChanged(bool value);
	void avpfEnabledChanged(bool value);
	void bundleModeEnabledChanged(bool value);
	void expireChanged(int value);
	void conferenceFactoryAddressChanged(QString value);
	void audioVideoConferenceFactoryAddressChanged(QString value);
	void limeServerUrlChanged(QString value);
	void removed();
	void voicemailCountChanged(int count);

private:
	// UserData
	static void setUserData(const std::shared_ptr<linphone::Account> &account, std::shared_ptr<AccountUserData> &data);
	static std::shared_ptr<AccountUserData> getUserData(const std::shared_ptr<linphone::Account> &account);
	static void removeUserData(const std::shared_ptr<linphone::Account> &account);

	DECLARE_ABSTRACT_OBJECT
};

// UserData : user data storage for linphone account information, that cannot be retrieved from Linphone account object
// through API, but received through listeners (example MWI/Voicemail count). Usually this is done using (s/g)etUserData
// on Linphone Objects on other wrappers, but not available in C++ Wrapper.

struct AccountUserData {
	int voicemailCount;
	// ..
};

#endif
