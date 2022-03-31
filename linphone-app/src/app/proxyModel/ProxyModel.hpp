/*
 * Copyright (c) 2022 Belledonne Communications SARL.
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

#ifndef PROXY_MODEL_H_
#define PROXY_MODEL_H_

#include <QSortFilterProxyModel>
#include <memory>

// =============================================================================

class ProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
	
public:
	Q_PROPERTY(int filterMode READ getFilterMode WRITE setFilterMode SIGNAL filterModeChanged)
	Q_PROPERTY(QAbstractItemModel * model READ getModel WRITE setModel SIGNAL modelChanged)
	
	ProxyModel (QObject *parent = Q_NULLPTR);
	ProxyModel (QAbstractItemModel * list, const int& defaultFilterMode, QObject *parent = Q_NULLPTR);
	
	int getFilterMode () const;
	void setFilterMode (int filterMode);
	
	Q_INVOKABLE QVariant getAt(int row);
	QAbstractItemModel *getModel();
	void setModel(QAbstractItemModel * model);
	
	//void add(std::shared_ptr<QObject> model);
public slots:
	void add(std::shared_ptr<QAbstractItemModel> model);
	
signals:
	void filterModeChanged(int);
	void modelChanged();
	void added(std::shared_ptr<QAbstractItemModel> model);
		
protected:
	bool filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const override;
	bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;
	
private:
	int mFilterMode;
};

#endif
