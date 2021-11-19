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
#include <QAbstractListModel>

class ContentModel;
class ChatMessageModel;

class ContentListModel : public QAbstractListModel {
	Q_OBJECT
	
public:
	ContentListModel (ChatMessageModel * message);
	
	int rowCount (const QModelIndex &index = QModelIndex()) const override;
	int count();
	
	virtual QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
	std::shared_ptr<ContentModel> getContentModel(std::shared_ptr<linphone::Content> content);// Return the contentModel by checking Content, or if it is the same file.
	void updateContent(std::shared_ptr<linphone::Content> oldContent, std::shared_ptr<linphone::Content> newContent);
	void updateContents(ChatMessageModel * messageModel);
	void updateAllTransferData();
	void downloaded();	// Contents have been downloaded, update all contents
	
signals:
	void updateTransferDataRequested();
	
private:
	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	virtual bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;
	
	QList<std::shared_ptr<ContentModel>> mList;
	
};

Q_DECLARE_METATYPE(std::shared_ptr<ContentListModel>)

#endif
