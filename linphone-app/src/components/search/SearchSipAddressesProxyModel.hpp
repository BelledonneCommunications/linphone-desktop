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

#ifndef SEARCH_SIP_ADDRESSES_PROXY_MODEL_H_
#define SEARCH_SIP_ADDRESSES_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

class ParticipantListModel;
class SearchSipAddressesModel;

// =============================================================================

class SearchSipAddressesProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
	
public:
	SearchSipAddressesProxyModel (QObject *parent = Q_NULLPTR);
	
	Q_PROPERTY(SearchSipAddressesModel * model READ getModel CONSTANT)
	Q_PROPERTY(ParticipantListModel *participantListModel READ getParticipantListModel WRITE setParticipantListModel NOTIFY  participantListModelChanged)
	
	Q_INVOKABLE void addAddressToIgnore(const QString& address);
	Q_INVOKABLE void removeAddressToIgnore(const QString& address);
	Q_INVOKABLE bool isIgnored(const QString& address) const;
	
	SearchSipAddressesModel * getModel();
	ParticipantListModel * getParticipantListModel() const;
	
	
	Q_INVOKABLE void setFilter (const QString &pattern);
	void setResultExceptions(QAbstractListModel* exceptionList);
	void setParticipantListModel( ParticipantListModel *model);
	
signals:
	void participantListModelChanged();
	void resultExceptionsChanged();
	
protected:
	bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
private:
	QMap<QString, bool> mResultsToIgnore;
	QString mFilter;
	ParticipantListModel *mParticipantListModel = nullptr;
};

#endif
