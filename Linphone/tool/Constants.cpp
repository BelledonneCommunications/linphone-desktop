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

#include "Constants.hpp"

constexpr char Constants::WindowIconPath[];
constexpr char Constants::DefaultLocale[];

constexpr char Constants::LanguagePath[];

// The main windows of Linphone desktop.
constexpr char Constants::QmlViewMainWindow[];
constexpr char Constants::QmlViewCallsWindow[];

#ifdef ENABLE_UPDATE_CHECK
constexpr int Constants::VersionUpdateCheckInterval;
#endif // ifdef ENABLE_UPDATE_CHECK

constexpr char Constants::MainQmlUri[];

constexpr char Constants::AttachVirtualWindowMethodName[];
constexpr char Constants::AboutPath[];

constexpr char Constants::AssistantViewName[];

constexpr char Constants::ApplicationMinimalQtVersion[];
constexpr char Constants::DefaultFont[];
constexpr int Constants::DefaultFontPointSize;
constexpr char Constants::DefaultEmojiFont[];
constexpr int Constants::DefaultEmojiFontPointSize;
QStringList Constants::getReactionsList() {
	return {"❤️", "👍", "😂", "😮", "😢"};
}
constexpr char Constants::AppDomain[];
constexpr size_t Constants::MaxLogsCollectionSize;
constexpr char Constants::SrcPattern[];
constexpr char Constants::LinphoneLocaleEncoding[];

constexpr char Constants::PathAssistantConfig[];
constexpr char Constants::PathAvatars[];
constexpr char Constants::PathCaptures[];
constexpr char Constants::PathCodecs[];
constexpr char Constants::PathData[];
constexpr char Constants::PathTools[];
constexpr char Constants::PathLogs[];
#ifdef APPLE
constexpr char Constants::PathPlugins[];
#else
constexpr char Constants::PathPlugins[];
#endif
constexpr char Constants::PathPluginsApp[];
constexpr char Constants::PathSounds[];
constexpr char Constants::PathUserCertificates[];

constexpr char Constants::PathCallHistoryList[];
constexpr char Constants::PathConfig[];
constexpr char Constants::PathDatabase[];
constexpr char Constants::PathFactoryConfig[];
constexpr char Constants::PathFriendsList[];
constexpr char Constants::PathRootCa[];
constexpr char Constants::PathLimeDatabase[];
constexpr char Constants::PathMessageHistoryList[];
constexpr char Constants::PathZrtpSecrets[];

// Max image size in bytes. (100Kb)
constexpr qint64 Constants::MaxImageSize;
constexpr int Constants::ThumbnailImageFileWidth;
constexpr int Constants::ThumbnailImageFileHeight;

// In Bytes.
constexpr qint64 Constants::FileSizeLimit;

constexpr char Constants::DefaultXmlrpcUri[];
constexpr char Constants::DefaultUploadLogsServer[];
constexpr char Constants::RetiredUploadLogsServer[];
constexpr char Constants::DefaultConferenceURI[];
constexpr char Constants::DefaultVideoConferenceURI[];
constexpr char Constants::DefaultLimeServerURL[];
constexpr char Constants::DefaultFlexiAPIURL[];
constexpr char Constants::RemoteProvisioningURL[];
constexpr char Constants::DefaultAssistantRegistrationUrl[];
constexpr char Constants::DefaultAssistantLoginUrl[];
constexpr char Constants::DefaultAssistantLogoutUrl[];
constexpr char Constants::DefaultRouteAddress[];

constexpr char Constants::RemoteProvisioningBasicAuth[];
constexpr char Constants::OAuth2AuthorizationUrl[];
constexpr char Constants::OAuth2AccessTokenUrl[];
constexpr char Constants::OAuth2RedirectUri[];
constexpr char Constants::OAuth2Identifier[];
constexpr char Constants::OAuth2Password[];
constexpr char Constants::OAuth2Scope[];
constexpr char Constants::DefaultOAuth2RemoteProvisioningHeader[];

#if defined(Q_OS_LINUX) || defined(Q_OS_WIN)
constexpr char Constants::H264Description[];
#endif // if defined(Q_OS_LINUX) || defined(Q_OS_WIN)

#ifdef Q_OS_LINUX
constexpr char Constants::LibraryExtension[];
constexpr char Constants::H264InstallName[];
#ifdef Q_PROCESSOR_X86_64
constexpr char Constants::PluginUrlH264[];
constexpr char Constants::PluginH264Check[];
#else
constexpr char Constants::PluginUrlH264[];
constexpr char Constants::PluginH264Check[];
#endif // ifdef Q_PROCESSOR_X86_64
#elif defined(Q_OS_WIN)
constexpr char Constants::LibraryExtension[];
constexpr char Constants::H264InstallName[];
#ifdef Q_OS_WIN64
constexpr char Constants::PluginUrlH264[];
constexpr char Constants::PluginH264Check[];
#else
constexpr char Constants::PluginUrlH264[];
constexpr char Constants::PluginH264Check[];
#endif // ifdef Q_OS_WIN64
#endif // ifdef Q_OS_LINUX
constexpr char Constants::VcardScheme[];

constexpr int Constants::CbsCallInterval;

constexpr char Constants::RcVersionName[];
constexpr int Constants::RcVersionCurrent;

// TODO: Remove hardcoded values. Use config directly.
constexpr char Constants::LinphoneDomain[];
constexpr char Constants::DefaultContactParameters[];
constexpr char Constants::DefaultContactParametersOnRemove[];
constexpr int Constants::DefaultExpires;
constexpr int Constants::DefaultPublishExpires;
constexpr char Constants::DownloadUrl[];
constexpr char Constants::VersionCheckReleaseUrl[];
constexpr char Constants::VersionCheckNightlyUrl[];
constexpr char Constants::PasswordRecoveryUrl[];
constexpr char Constants::CguUrl[];
constexpr char Constants::PrivatePolicyUrl[];
constexpr char Constants::ContactUrl[];
constexpr char Constants::TranslationUrl[];

constexpr int Constants::MaxMosaicParticipants;

constexpr char Constants::LinphoneBZip2_exe[];
constexpr char Constants::LinphoneBZip2_dll[];
constexpr char Constants::DefaultRlsUri[];
constexpr char Constants::DefaultLogsEmail[];
constexpr char Constants::DownloadDefaultFileName[];
