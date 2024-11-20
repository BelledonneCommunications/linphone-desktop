/*
 * Copyright (c) 2022-2024 Belledonne Communications SARL.
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

#ifndef SORT_FILTER_PROXY_H_
#define SORT_FILTER_PROXY_H_

#include <QSortFilterProxyModel>
#define DECLARE_SORTFILTER_CLASS(...)                                                                                  \
	class SortFilterList : public SortFilterProxy {                                                                    \
	public:                                                                                                            \
		SortFilterList(QAbstractItemModel *list) : SortFilterProxy(list) {                                             \
		}                                                                                                              \
		SortFilterList(QAbstractItemModel *list, Qt::SortOrder order) : SortFilterProxy(list, order) {                 \
		}                                                                                                              \
		virtual bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;                  \
		virtual bool lessThan(const QModelIndex &sourceLeft, const QModelIndex &sourceRight) const override;           \
		__VA_ARGS__                                                                                                    \
	};

class SortFilterProxy : public QSortFilterProxyModel {
	Q_OBJECT
public:
	Q_PROPERTY(int count READ getCount NOTIFY countChanged)
	Q_PROPERTY(int filterType READ getFilterType WRITE setFilterType NOTIFY filterTypeChanged)
	Q_PROPERTY(QString filterText READ getFilterText WRITE setFilterText NOTIFY filterTextChanged)

	SortFilterProxy(QAbstractItemModel *parent);
	SortFilterProxy(QAbstractItemModel *parent, Qt::SortOrder order);
	virtual ~SortFilterProxy();
	virtual void deleteSourceModel();
	virtual void setSourceModel(QAbstractItemModel *sourceModel) override;

	virtual int getCount() const;

	Q_INVOKABLE QVariant getAt(const int &index) const;
	template <class A, class B>
	QSharedPointer<B> getItemAt(const int &atIndex) const {
		auto modelIndex = index(atIndex, 0);
		return qobject_cast<A *>(sourceModel())->template getAt<B>(mapToSource(modelIndex).row());
	}
	template <class A, class B>
	QSharedPointer<B> getItemAtSource(const int &atIndex) const {
		return qobject_cast<A *>(sourceModel())->template getAt<B>(atIndex);
	}

	virtual int getFilterType() const;
	virtual void setFilterType(int filterType);

	Q_INVOKABLE void setSortOrder(const Qt::SortOrder &order);

	QString getFilterText() const;
	void setFilterText(const QString &filter);

	Q_INVOKABLE void remove(int index, int count = 1);
	void invalidateFilter();

	int mFilterType = 0;
	QString mFilterText;

signals:
	void countChanged();
	void filterTypeChanged(int filterType);
	void filterTextChanged();

protected:
	bool mDeleteSourceModel = false;
};

#endif
