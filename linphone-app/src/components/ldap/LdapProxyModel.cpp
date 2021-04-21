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

#include "components/core/CoreManager.hpp"

#include "LdapModel.hpp"
#include "LdapListModel.hpp"
#include "LdapProxyModel.hpp"

// -----------------------------------------------------------------------------

LdapProxyModel::LdapProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
  setSourceModel(CoreManager::getInstance()->getLdapListModel());
  sort(0);
}

// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------

bool LdapProxyModel::filterAcceptsRow (int sourceRow, const QModelIndex &sourceParent) const {
  const QModelIndex index = sourceModel()->index(sourceRow, 0, sourceParent);
  return true;
}

bool LdapProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
    const LdapModel* ldapA = sourceModel()->data(left).value<LdapModel*>();
    const LdapModel* ldapB = sourceModel()->data(right).value<LdapModel*>();
  
    return ldapA->mId <= ldapB->mId;
}
