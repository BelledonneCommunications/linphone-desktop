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

#ifndef SORT_FILTER_PROXY_MODEL_H_
#define SORT_FILTER_PROXY_MODEL_H_

#include <QSortFilterProxyModel>

class SortFilterProxyModel : public QSortFilterProxyModel {
	Q_OBJECT
public:
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)
	Q_PROPERTY(int filterType READ getFilterType WRITE setFilterType NOTIFY filterTypeChanged)
	
	SortFilterProxyModel(QObject * parent = nullptr);
	virtual ~SortFilterProxyModel();
	virtual void deleteSourceModel();
	
	virtual int getCount() const;
	virtual int getFilterType () const;
	Q_INVOKABLE QVariant getAt(const int& index) const;
	Q_INVOKABLE void setSortOrder(const Qt::SortOrder& order);
	
	virtual void setFilterType (int filterType);
	
	Q_INVOKABLE void remove(int index, int count = 1);
	

signals:
	void countChanged();
	void filterTypeChanged(int filterType);
	
protected:
	int mFilterType;
	bool mDeleteSourceModel = false;
};

#endif
