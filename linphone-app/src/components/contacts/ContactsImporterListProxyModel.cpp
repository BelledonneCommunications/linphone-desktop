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

#include <cmath>

#include "components/contacts/ContactsImporterModel.hpp"
#include "components/core/CoreManager.hpp"
#include "utils/Utils.hpp"

#include "ContactsImporterListModel.hpp"
#include "ContactsImporterListProxyModel.hpp"

// =============================================================================

using namespace std;



// -----------------------------------------------------------------------------

ContactsImporterListProxyModel::ContactsImporterListProxyModel (QObject *parent) : QSortFilterProxyModel(parent) {
	setSourceModel(CoreManager::getInstance()->getContactsImporterListModel());
	sort(0);// Sort by identity
}

// -----------------------------------------------------------------------------

bool ContactsImporterListProxyModel::filterAcceptsRow (
  int sourceRow,
  const QModelIndex &sourceParent
) const {
	Q_UNUSED(sourceRow)
	Q_UNUSED(sourceParent)
	return true;
}

bool ContactsImporterListProxyModel::lessThan (const QModelIndex &left, const QModelIndex &right) const {
  const ContactsImporterModel *contactA = sourceModel()->data(left).value<ContactsImporterModel *>();
  const ContactsImporterModel *contactB = sourceModel()->data(right).value<ContactsImporterModel *>();

  return contactA->getIdentity() <= contactB->getIdentity();
}

// -----------------------------------------------------------------------------
