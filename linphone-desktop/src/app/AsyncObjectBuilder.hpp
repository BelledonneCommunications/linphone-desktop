/*
 * AsyncObjectBuilder.hpp
 * Copyright (C) 2017  Belledonne Communications, Grenoble, France
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *  Created on: March 27, 2017
 *      Author: Ronan Abhamon
 */

#ifndef ASYNC_OBJECT_BUILDER_H_
#define ASYNC_OBJECT_BUILDER_H_

#include <functional>

#include <QQmlEngine>
#include <QQmlComponent>

// =============================================================================

class AsyncObjectBuilder : public QObject {
  Q_OBJECT;

  class ObjectIncubator;

  typedef std::function<void (QObject *)> Decorator;

public:
  AsyncObjectBuilder (QObject *parent = Q_NULLPTR);
  ~AsyncObjectBuilder ();

  void createObject (QQmlEngine *engine, const char *path, Decorator decorator = nullptr);
  QObject *getObject () const;

  bool isCreated () const {
    return m_is_created;
  }

signals:
  void objectCreated (QObject *object);

private:
  void handleComponentCreation (QQmlComponent::Status status);

  ObjectIncubator *m_incubator = nullptr;
  QQmlComponent *m_component = nullptr;

  Decorator m_decorator;

  QObject *m_object = nullptr;

  bool m_is_created = false;

  #ifdef QT_DEBUG
    bool m_block_creation = false;
  #endif // ifdef QT_DEBUG
};

#endif // ASYNC_OBJECT_BUILDER_H_
