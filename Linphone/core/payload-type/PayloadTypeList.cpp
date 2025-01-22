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

#include "PayloadTypeList.hpp"
#include "DownloadablePayloadTypeCore.hpp"
#include "PayloadTypeGui.hpp"
#include "core/App.hpp"
#include "core/path/Paths.hpp"
#include "model/object/VariantObject.hpp"
#include "model/tool/ToolModel.hpp"
#include <QSharedPointer>
#include <linphone++/linphone.hh>

// =============================================================================

DEFINE_ABSTRACT_OBJECT(PayloadTypeList)

QSharedPointer<PayloadTypeList> PayloadTypeList::create() {
	auto model = QSharedPointer<PayloadTypeList>(new PayloadTypeList(), &QObject::deleteLater);
	model->moveToThread(App::getInstance()->thread());
	model->setSelf(model);
	return model;
}

PayloadTypeList::PayloadTypeList(QObject *parent) : ListProxy(parent) {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	App::getInstance()->mEngine->setObjectOwnership(this, QQmlEngine::CppOwnership);
}

PayloadTypeList::~PayloadTypeList() {
	mustBeInMainThread(log().arg(Q_FUNC_INFO));
	mModelConnection = nullptr;
}

void PayloadTypeList::setSelf(QSharedPointer<PayloadTypeList> me) {
	mModelConnection = SafeConnection<PayloadTypeList, CoreModel>::create(me, CoreModel::getInstance());
	mModelConnection->makeConnectToCore(&PayloadTypeList::lUpdate, [this]() {
		mModelConnection->invokeToModel([this]() {
			QList<QSharedPointer<PayloadTypeCore>> *payloadTypes = new QList<QSharedPointer<PayloadTypeCore>>();
			mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));

			ToolModel::loadDownloadedCodecs();

			// Audio
			for (auto payloadType : CoreModel::getInstance()->getCore()->getAudioPayloadTypes()) {
				auto core = PayloadTypeCore::create(PayloadTypeCore::Family::Audio, payloadType);
				payloadTypes->push_back(core);
			}

			// Video
			auto videoCodecs = CoreModel::getInstance()->getCore()->getVideoPayloadTypes();
			for (auto payloadType : videoCodecs) {
				auto core = PayloadTypeCore::create(PayloadTypeCore::Family::Video, payloadType);
				payloadTypes->push_back(core);
			}

			// Downloadable Video
			for (auto downloadableVideoCodec : Utils::getDownloadableVideoPayloadTypes()) {
				if (find_if(videoCodecs.begin(), videoCodecs.end(),
				            [downloadableVideoCodec](const std::shared_ptr<linphone::PayloadType> &codec) {
					            return Utils::coreStringToAppString(codec->getMimeType()) ==
					                   downloadableVideoCodec->getMimeType();
				            }) == videoCodecs.end())
					payloadTypes->append(downloadableVideoCodec.dynamicCast<PayloadTypeCore>());
			}

			// Text
			for (auto payloadType : CoreModel::getInstance()->getCore()->getTextPayloadTypes()) {
				auto core = PayloadTypeCore::create(PayloadTypeCore::Family::Text, payloadType);
				payloadTypes->push_back(core);
			}
			mModelConnection->invokeToCore([this, payloadTypes]() {
				mustBeInMainThread(log().arg(Q_FUNC_INFO));
				resetData<PayloadTypeCore>(*payloadTypes);
				delete payloadTypes;
			});
		});
	});

	mModelConnection->makeConnectToModel(&CoreModel::configuringStatus,
	                                     [this](const std::shared_ptr<linphone::Core> &core,
	                                            linphone::ConfiguringState status, const std::string &message) {
		                                     mustBeInLinphoneThread(log().arg(Q_FUNC_INFO));
		                                     if (status == linphone::ConfiguringState::Successful) emit lUpdate();
	                                     });

	emit lUpdate();
}

QVariant PayloadTypeList::data(const QModelIndex &index, int role) const {
	int row = index.row();
	if (!index.isValid() || row < 0 || row >= mList.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		return QVariant::fromValue(new PayloadTypeGui(mList[row].objectCast<PayloadTypeCore>()));
	}
	return QVariant();
}
