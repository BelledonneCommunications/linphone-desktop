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

#ifndef ACCOUNT_CORE_H_
#define ACCOUNT_CORE_H_

#include "model/account/AccountModel.hpp"
#include "tool/LinphoneEnums.hpp"
#include "tool/thread/SafeConnection.hpp"
#include <QObject>
#include <QSharedPointer>
#include <linphone++/linphone.hh>

class AccountCore : public QObject, public AbstractObject {
	Q_OBJECT

	Q_PROPERTY(QString contactAddress READ getContactAddress CONSTANT)
	Q_PROPERTY(QString identityAddress READ getIdentityAddress CONSTANT)
	Q_PROPERTY(QString pictureUri READ getPictureUri WRITE lSetPictureUri NOTIFY pictureUriChanged)
	Q_PROPERTY(
	    LinphoneEnums::RegistrationState registrationState READ getRegistrationState NOTIFY registrationStateChanged)
	Q_PROPERTY(bool isDefaultAccount READ getIsDefaultAccount NOTIFY defaultAccountChanged)
	Q_PROPERTY(int unreadNotifications READ getUnreadNotifications NOTIFY unreadNotificationsChanged)
	Q_PROPERTY(int unreadCallNotifications READ getUnreadCallNotifications NOTIFY unreadCallNotificationsChanged)
	Q_PROPERTY(
	    int unreadMessageNotifications READ getUnreadMessageNotifications NOTIFY unreadMessageNotificationsChanged)
	Q_PROPERTY(QString displayName READ getDisplayName WRITE lSetDisplayName NOTIFY displayNameChanged)
	Q_PROPERTY(QStringList dialPlans READ getDialPlans CONSTANT)
	Q_PROPERTY(QString dialPlan READ getDialPlan WRITE lSetDialPlan NOTIFY dialPlanChanged)
	Q_PROPERTY(
	    QString humaneReadableRegistrationState READ getHumanReadableRegistrationState NOTIFY registrationStateChanged)
	Q_PROPERTY(QString humaneReadableRegistrationStateExplained READ getHumanReadableRegistrationStateExplained NOTIFY
	               registrationStateChanged)
	Q_PROPERTY(bool registerEnabled READ getRegisterEnabled WRITE lSetRegisterEnabled NOTIFY registerEnabledChanged)
	Q_PROPERTY(QVariantList devices MEMBER mDevices NOTIFY devicesChanged)

	Q_PROPERTY(bool notificationsAllowed READ getNotificationsAllowed WRITE lSetNotificationsAllowed NOTIFY
	               notificationsAllowedChanged)
	Q_PROPERTY(
	    QString mwiServerAddress READ getMwiServerAddress WRITE lSetMwiServerAddress NOTIFY mwiServerAddressChanged)
	Q_PROPERTY(QStringList transports READ getTransports CONSTANT)
	Q_PROPERTY(QString transport READ getTransport WRITE lSetTransport NOTIFY transportChanged)
	Q_PROPERTY(QString serverAddress READ getServerAddress WRITE lSetServerAddress NOTIFY serverAddressChanged)
	Q_PROPERTY(bool outboundProxyEnabled READ getOutboundProxyEnabled WRITE lSetOutboundProxyEnabled NOTIFY
	               outboundProxyEnabledChanged)
	Q_PROPERTY(QString stunServer READ getStunServer WRITE lSetStunServer NOTIFY stunServerChanged)
	Q_PROPERTY(bool iceEnabled READ getIceEnabled WRITE lSetIceEnabled NOTIFY iceEnabledChanged)
	Q_PROPERTY(bool avpfEnabled READ getAvpfEnabled WRITE lSetAvpfEnabled NOTIFY avpfEnabledChanged)
	Q_PROPERTY(
	    bool bundleModeEnabled READ getBundleModeEnabled WRITE lSetBundleModeEnabled NOTIFY bundleModeEnabledChanged)
	Q_PROPERTY(int expire READ getExpire WRITE lSetExpire NOTIFY expireChanged)
	Q_PROPERTY(QString conferenceFactoryAddress READ getConferenceFactoryAddress WRITE lSetConferenceFactoryAddress
	               NOTIFY conferenceFactoryAddressChanged)
	Q_PROPERTY(QString audioVideoConferenceFactoryAddress READ getAudioVideoConferenceFactoryAddress WRITE
	               lSetAudioVideoConferenceFactoryAddress NOTIFY audioVideoConferenceFactoryAddressChanged)
	Q_PROPERTY(QString limeServerUrl READ getLimeServerUrl WRITE lSetLimeServerUrl NOTIFY limeServerUrlChanged)
	DECLARE_CORE_GET(int, voicemailCount, VoicemailCount)

public:
	static QSharedPointer<AccountCore> create(const std::shared_ptr<linphone::Account> &account);
	// Should be call from model Thread. Will be automatically in App thread after initialization
	AccountCore(const std::shared_ptr<linphone::Account> &account);
	~AccountCore();
	void setSelf(QSharedPointer<AccountCore> me);

	const std::shared_ptr<AccountModel> &getModel() const;

	QString getContactAddress() const;
	QString getIdentityAddress() const;
	QString getPictureUri() const;
	void onPictureUriChanged(QString uri);
	LinphoneEnums::RegistrationState getRegistrationState() const;
	bool getIsDefaultAccount() const;
	int getUnreadNotifications() const;
	void setUnreadNotifications(int unread);
	int getUnreadCallNotifications() const;
	void setUnreadCallNotifications(int unread);
	int getUnreadMessageNotifications() const;
	void setUnreadMessageNotifications(int unread);

	void onRegistrationStateChanged(const std::shared_ptr<linphone::Account> &account,
	                                linphone::RegistrationState state,
	                                const std::string &message);

	void onDefaultAccountChanged(bool isDefault);
	Q_INVOKABLE void removeAccount();
	QString getDisplayName() const;
	void onDisplayNameChanged(QString displayName);
	QStringList getDialPlans();
	int getDialPlanIndex(QString dialPlanString);
	QString getDialPlan() const;
	void onDialPlanChanged(QString internationalPrefix);
	QString getHumanReadableRegistrationState() const;
	QString getHumanReadableRegistrationStateExplained() const;
	bool getRegisterEnabled() const;
	void onRegisterEnabledChanged(bool enabled);

	bool getNotificationsAllowed();
	QString getMwiServerAddress();
	QString getTransport();
	QStringList getTransports();
	QString getServerAddress();
	bool getOutboundProxyEnabled();
	QString getStunServer();
	bool getIceEnabled();
	bool getAvpfEnabled();
	bool getBundleModeEnabled();
	int getExpire();
	QString getConferenceFactoryAddress();
	QString getAudioVideoConferenceFactoryAddress();
	QString getLimeServerUrl();

	void onNotificationsAllowedChanged(bool value);
	void onMwiServerAddressChanged(QString value);
	void onTransportChanged(QString value);
	void onServerAddressChanged(QString value);
	void onOutboundProxyEnabledChanged(bool value);
	void onStunServerChanged(QString value);
	void onIceEnabledChanged(bool value);
	void onAvpfEnabledChanged(bool value);
	void onBundleModeEnabledChanged(bool value);
	void onExpireChanged(int value);
	void onConferenceFactoryAddressChanged(QString value);
	void onAudioVideoConferenceFactoryAddressChanged(QString value);
	void onLimeServerUrlChanged(QString value);

signals:
	void pictureUriChanged();
	void registrationStateChanged(const QString &message);
	void defaultAccountChanged(bool isDefault);
	void unreadNotificationsChanged(int unread);
	void unreadCallNotificationsChanged(int unread);
	void unreadMessageNotificationsChanged(int unread);
	void displayNameChanged();
	void dialPlanChanged();
	void registerEnabledChanged();
	void allAddressesChanged();
	void devicesChanged();
	void notificationsAllowedChanged();
	void mwiServerAddressChanged();
	void transportChanged();
	void serverAddressChanged();
	void outboundProxyEnabledChanged();
	void stunServerChanged();
	void iceEnabledChanged();
	void avpfEnabledChanged();
	void bundleModeEnabledChanged();
	void expireChanged();
	void conferenceFactoryAddressChanged();
	void audioVideoConferenceFactoryAddressChanged();
	void limeServerUrlChanged();
	void removed();

	// Account requests
	void lSetPictureUri(QString pictureUri);
	void lSetDefaultAccount();
	void lResetMissedCalls();
	void lRefreshNotifications();
	void lSetDisplayName(QString displayName);
	void lSetDialPlan(QString internationalPrefix);
	void lSetRegisterEnabled(bool enabled);
	void lSetNotificationsAllowed(bool value);
	void lSetMwiServerAddress(QString value);
	void lSetTransport(QString value);
	void lSetServerAddress(QString value);
	void lSetOutboundProxyEnabled(bool value);
	void lSetStunServer(QString value);
	void lSetIceEnabled(bool value);
	void lSetAvpfEnabled(bool value);
	void lSetBundleModeEnabled(bool value);
	void lSetExpire(int value);
	void lSetConferenceFactoryAddress(QString value);
	void lSetAudioVideoConferenceFactoryAddress(QString value);
	void lSetLimeServerUrl(QString value);

private:
	QString mContactAddress;
	QString mIdentityAddress;
	QString mPictureUri;
	QString mDisplayName;
	QStringList mDialPlans;
	QString mDialPlan;
	bool mRegisterEnabled;
	bool mIsDefaultAccount = false;
	LinphoneEnums::RegistrationState mRegistrationState;
	int mUnreadNotifications = 0;
	int mUnreadCallNotifications = 0;
	int mUnreadMessageNotifications = 0;
	QVariantList mDevices;
	bool mNotificationsAllowed;
	QString mMwiServerAddress;
	QString mTransport;
	QStringList mTransports;
	QString mServerAddress;
	bool mOutboundProxyEnabled;
	QString mStunServer;
	bool mIceEnabled;
	bool mAvpfEnabled;
	bool mBundleModeEnabled;
	int mExpire;
	QString mConferenceFactoryAddress;
	QString mAudioVideoConferenceFactoryAddress;
	QString mLimeServerUrl;

	std::shared_ptr<AccountModel> mAccountModel;
	QSharedPointer<SafeConnection<AccountCore, AccountModel>> mAccountModelConnection;
	QSharedPointer<SafeConnection<AccountCore, CoreModel>> mCoreModelConnection;

	DECLARE_ABSTRACT_OBJECT
};

#endif
