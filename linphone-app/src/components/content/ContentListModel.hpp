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

#ifndef CONTENT_LIST_MODEL_H_
#define CONTENT_LIST_MODEL_H_


#include <linphone++/linphone.hh>
// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>

#include "app/proxyModel/ProxyListModel.hpp"

class ContentModel;
class ChatMessageModel;

class ContentListModel : public ProxyListModel {
	Q_OBJECT
	
public:
	ContentListModel (ChatMessageModel * message, QObject * parent = nullptr);
	
	int count();
	
	QSharedPointer<ContentModel> add(std::shared_ptr<linphone::Content> content);
	void addFile(QString path);
	Q_INVOKABLE void remove(ContentModel * model);
	
	void clear();
	void removeDownloadedFiles();
	
	QSharedPointer<ContentModel> getContentModel(std::shared_ptr<linphone::Content> content);// Return the contentModel by checking Content, or if it is the same file.
	
	void updateContent(std::shared_ptr<linphone::Content> oldContent, std::shared_ptr<linphone::Content> newContent);
	void updateContents(ChatMessageModel * messageModel);
	void updateAllTransferData();
	void downloaded();	// Contents have been downloaded, update all contents
	
signals:
	void updateTransferDataRequested();
	void contentsChanged();
	
private:
	
	ChatMessageModel * mParent;
	
};

Q_DECLARE_METATYPE(std::shared_ptr<ContentListModel>)

#endif
