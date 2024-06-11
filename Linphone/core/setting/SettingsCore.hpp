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
	
	// Security
	Q_PROPERTY(bool vfsEnabled READ getVfsEnabled WRITE setVfsEnabled NOTIFY vfsEnabledChanged)

	// Call
	Q_PROPERTY(bool videoEnabled READ getVideoEnabled WRITE setVideoEnabled NOTIFY videoEnabledChanged)
	Q_PROPERTY(bool echoCancellationEnabled READ getEchoCancellationEnabled WRITE setEchoCancellationEnabled NOTIFY echoCancellationEnabledChanged)
	Q_PROPERTY(int echoCancellationCalibration READ getEchoCancellationCalibration NOTIFY echoCancellationCalibrationChanged)
	Q_PROPERTY(bool automaticallyRecordCallsEnabled READ getAutomaticallyRecordCallsEnabled WRITE setAutomaticallyRecordCallsEnabled NOTIFY automaticallyRecordCallsEnabledChanged)
	
	Q_PROPERTY(bool captureGraphRunning READ getCaptureGraphRunning NOTIFY captureGraphRunningChanged)
	
	Q_PROPERTY(QStringList captureDevices READ getCaptureDevices NOTIFY captureDevicesChanged)
	Q_PROPERTY(QStringList playbackDevices READ getPlaybackDevices NOTIFY playbackDevicesChanged)
	
	Q_PROPERTY(float playbackGain READ getPlaybackGain WRITE setPlaybackGain NOTIFY playbackGainChanged)
	Q_PROPERTY(float captureGain READ getCaptureGain WRITE setCaptureGain NOTIFY captureGainChanged)
	
	Q_PROPERTY(QString captureDevice READ getCaptureDevice WRITE setCaptureDevice NOTIFY captureDeviceChanged)
	Q_PROPERTY(QString playbackDevice READ getPlaybackDevice WRITE setPlaybackDevice NOTIFY playbackDeviceChanged)
	Q_PROPERTY(QString ringerDevice READ getRingerDevice WRITE setRingerDevice NOTIFY ringerDeviceChanged)
	
	Q_PROPERTY(QStringList videoDevices READ getVideoDevices NOTIFY videoDevicesChanged)
	Q_PROPERTY(QString videoDevice READ getVideoDevice WRITE setVideoDevice NOTIFY videoDeviceChanged)
	
	Q_PROPERTY(float micVolume MEMBER _dummy_int NOTIFY micVolumeChanged)
	
	Q_PROPERTY(bool logsEnabled READ getLogsEnabled WRITE setLogsEnabled NOTIFY logsEnabledChanged)
	Q_PROPERTY(bool fullLogsEnabled READ getFullLogsEnabled WRITE setFullLogsEnabled NOTIFY fullLogsEnabledChanged)
	Q_PROPERTY(QString logsEmail READ getLogsEmail)
	Q_PROPERTY(QString logsFolder READ getLogsFolder)


public:
	static QSharedPointer<Settings> create();
	Settings(QObject *parent = Q_NULLPTR);
	virtual ~Settings();

	void setSelf(QSharedPointer<Settings> me);

	QString getConfigPath(const QCommandLineParser &parser = QCommandLineParser());

	Q_INVOKABLE void setFirstLaunch(bool first);
	Q_INVOKABLE bool getFirstLaunch() const;
	
	// Security. --------------------------------------------------------------------
	bool getVfsEnabled() { return mVfsEnabled; }
	
	// Call. --------------------------------------------------------------------
	
	bool getVideoEnabled() { return mVideoEnabled; }
	bool getEchoCancellationEnabled()  { return mEchoCancellationEnabled; }
	bool getAutomaticallyRecordCallsEnabled()  { return mAutomaticallyRecordCallsEnabled; }
		
	float getPlaybackGain() const;
	
	float getCaptureGain() const;
	
	QStringList getCaptureDevices () const;
	QStringList getPlaybackDevices () const;
	
	QString getCaptureDevice () const;
	
	QString getPlaybackDevice () const;
	
	QString getRingerDevice () const;
	
	QString getVideoDevice()  { return mVideoDevice; }
	QStringList getVideoDevices() const;
	
	bool getCaptureGraphRunning();

	Q_INVOKABLE void startEchoCancellerCalibration();
	int getEchoCancellationCalibration() const;
	
	Q_INVOKABLE void accessCallSettings();
	Q_INVOKABLE void closeCallSettings();
	Q_INVOKABLE void updateMicVolume() const;
	
	bool getLogsEnabled () const;
	bool getFullLogsEnabled () const;
	
	Q_INVOKABLE void cleanLogs () const;
	Q_INVOKABLE void sendLogs () const;
	QString getLogsEmail () const;
	QString getLogsFolder () const;


signals:
	
	// Security
	void setVfsEnabled(const bool enabled);
	void vfsEnabledChanged();
	
	// Call
	void setVideoEnabled(const bool enabled);
	void videoEnabledChanged();
	
	void setEchoCancellationEnabled(const bool enabled);
	void echoCancellationEnabledChanged();
	
	void setAutomaticallyRecordCallsEnabled(const bool enabled);
	void automaticallyRecordCallsEnabledChanged();
	
	void captureGraphRunningChanged(bool running);
	
	void playbackGainChanged(float gain);
	void captureGainChanged(float gain);
	
	void captureDevicesChanged (const QStringList &devices);
	void playbackDevicesChanged (const QStringList &devices);
	
	void setCaptureDevice (const QString &device);
	void captureDeviceChanged (const QString &device);
	
	void setPlaybackDevice (const QString &device);
	void playbackDeviceChanged (const QString &device);
	void ringerDeviceChanged (const QString &device);

	void setVideoDevice(const QString &device);
	void videoDeviceChanged();
	void videoDevicesChanged();
	
	void setCaptureGain(float gain);
	void setPlaybackGain(float gain);
	void setRingerDevice (const QString &device);

	void echoCancellationCalibrationChanged();
	void micVolumeChanged(float volume);
	
	void logsEnabledChanged ();
	void fullLogsEnabledChanged ();
	
	void setLogsEnabled (bool status);
	void setFullLogsEnabled (bool status);
	
	void logsUploadTerminated (bool status, QString url);
	void logsEmailChanged (const QString &email);
	void logsFolderChanged (const QString &folder);

private:
	std::shared_ptr<SettingsModel> mSettingsModel;
	
	// Dummy properties (for properties that use values from core received through signals)
	int _dummy_int = 0;
	
	// Security
	bool mVfsEnabled;
	
	// Call
	bool mVideoEnabled;
	bool mEchoCancellationEnabled;
	bool mAutomaticallyRecordCallsEnabled;

	// Audio
	QStringList mCaptureDevices;
	QStringList mPlaybackDevices;
	QString mCaptureDevice;
	QString mPlaybackDevice;
	QString mRingerDevice;
	
	// Video
	QStringList mVideoDevices;
	QString mVideoDevice;
	
	bool mCaptureGraphRunning;
	float mCaptureGain;
	float mPlaybackGain;
	int mEchoCancellationCalibration;
	
	//Debug logs
	bool mLogsEnabled;
	bool mFullLogsEnabled;
	QString mLogsFolder;
	QString mLogsEmail;
	
	QSettings mAppSettings;
	QSharedPointer<SafeConnection<Settings, SettingsModel>> mSettingsModelConnection;

	DECLARE_ABSTRACT_OBJECT
};
#endif
