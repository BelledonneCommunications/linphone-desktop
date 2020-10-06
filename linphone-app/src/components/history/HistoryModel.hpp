/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
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

#ifndef HISTORY_MODEL_H_
#define HISTORY_MODEL_H_

#include <linphone++/linphone.hh>
#include <QAbstractListModel>

// =============================================================================
// Fetch all N messages of the History.
// =============================================================================

class CoreHandlers;

class HistoryModel : public QAbstractListModel {
	
	Q_OBJECT

public:
	enum Roles {
		HistoryEntry = Qt::DisplayRole,
		SectionDate
	};

	enum EntryType {
		GenericEntry,
		CallEntry
	};
	Q_ENUM(EntryType)

	enum CallStatus {
		CallStatusDeclined = int(linphone::Call::Status::Declined),
		CallStatusMissed = int(linphone::Call::Status::Missed),
		CallStatusSuccess = int(linphone::Call::Status::Success),
		CallStatusAborted = int(linphone::Call::Status::Aborted),
		CallStatusEarlyAborted = int(linphone::Call::Status::EarlyAborted),
		CallStatusAcceptedElsewhere = int(linphone::Call::Status::AcceptedElsewhere),
		CallStatusDeclinedElsewhere = int(linphone::Call::Status::DeclinedElsewhere)
	};
	Q_ENUM(CallStatus)

	HistoryModel (QObject *parent = Q_NULLPTR);
	virtual ~HistoryModel ();

	int rowCount (const QModelIndex &index = QModelIndex()) const override;

	QHash<int, QByteArray> roleNames () const override;
	QVariant data (const QModelIndex &index, int role) const override;

	bool removeRow (int row, const QModelIndex &parent = QModelIndex());
	bool removeRows (int row, int count, const QModelIndex &parent = QModelIndex()) override;

	void removeEntry (int id);
	void removeAllEntries ();
	
	void resetMessageCount ();

signals:
	void allEntriesRemoved ();
	void lastEntryRemoved ();

	void focused ();
	void callCountReset();

private:
	typedef QPair<QVariantMap, std::shared_ptr<void>> HistoryEntryData;
	
	void setSipAddresses ();
	void removeEntry (HistoryEntryData &entry);
	void insertCall (const std::shared_ptr<linphone::CallLog> &callLog);
	void handleCallStateChanged (const std::shared_ptr<linphone::Call> &call, linphone::Call::State state);

	mutable QList<HistoryEntryData> mEntries;
	
	std::shared_ptr<CoreHandlers> mCoreHandlers;
};

#endif // HISTORY_MODEL_H_
