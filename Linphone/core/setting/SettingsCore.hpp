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

#ifndef SETTINGS_H_
#define SETTINGS_H_

#include "model/setting/SettingsModel.hpp"
#include "tool/thread/SafeConnection.hpp"

#include <QCommandLineParser>
#include <QObject>
#include <QSettings>
#include <QVariantMap>

class Settings : public QObject, public AbstractObject {
	Q_OBJECT
	Q_PROPERTY(QStringList inputAudioDevicesList READ getInputAudioDevicesList NOTIFY inputAudioDeviceChanged)
	Q_PROPERTY(QStringList outputAudioDevicesList READ getOutputAudioDevicesList NOTIFY outputAudioDeviceChanged)
	Q_PROPERTY(QStringList videoDevicesList READ getVideoDevicesList NOTIFY videoDeviceChanged)
	Q_PROPERTY(int currentVideoDeviceIndex READ getCurrentVideoDeviceIndex NOTIFY videoDeviceChanged)
public:
	static QSharedPointer<Settings> create();
	Settings(QObject *parent = Q_NULLPTR);
	virtual ~Settings();

	void setSelf(QSharedPointer<Settings> me);

	QString getConfigPath(const QCommandLineParser &parser = QCommandLineParser());

	QStringList getInputAudioDevicesList() const;

	QStringList getOutputAudioDevicesList() const;

	QStringList getVideoDevicesList() const;

	void setCurrentVideoDevice(const QString &id);
	int getCurrentVideoDeviceIndex();

	Q_INVOKABLE void setFirstLaunch(bool first);
	Q_INVOKABLE bool getFirstLaunch() const;

signals:
	void inputAudioDeviceChanged(const QString &id);
	void outputAudioDeviceChanged(const QString &id);
	void videoDeviceChanged();

	void lSetInputAudioDevice(const QString &device);
	void lSetOutputAudioDevice(const QString &device);
	void lSetVideoDevice(const QString &device);

private:
	std::shared_ptr<SettingsModel> mSettingsModel;
	QStringList mInputAudioDevices;
	QString mCurrentVideoDeviceId;
	QStringList mOutputAudioDevices;
	QStringList mVideoDevices;
	QSettings mAppSettings;
	QSharedPointer<SafeConnection<Settings, SettingsModel>> mSettingsModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
#endif
