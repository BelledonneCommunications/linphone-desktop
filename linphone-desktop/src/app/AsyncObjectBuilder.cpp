/*
 * AsyncObjectBuilder.cpp
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

#include <QCoreApplication>
#include <QDebug>
#include <QQmlIncubator>

#include "AsyncObjectBuilder.hpp"

using namespace std;

// =============================================================================

class AsyncObjectBuilder::ObjectIncubator : public QQmlIncubator {
public:
  // FIXME: At this moment, asynchronous loading is unstable.
  // Use `IncubationMode::Synchronous` instead in Qt 5.9.
  //
  // See: https://bugreports.qt.io/browse/QTBUG-49416 and
  // https://bugreports.qt.io/browse/QTBUG-50992
  ObjectIncubator (AsyncObjectBuilder *builder) : QQmlIncubator(IncubationMode::Synchronous) {
    m_builder = builder;
  }

protected:
  void statusChanged (Status status) override {
    if (status == Error) {
      qWarning() << "ObjectIncubator failed to build component:" << errors();
      abort();
    }

    if (status == Ready) {
      QObject *object = QQmlIncubator::object();

      QQmlEngine::setObjectOwnership(object, QQmlEngine::CppOwnership);
      object->setParent(m_builder);

      m_builder->m_is_created = true;

      // Call user decorator.
      if (m_builder->m_decorator)
        m_builder->m_decorator(object);

      qInfo() << QStringLiteral("Creation of component instance is successful:") << m_builder->m_component;

      m_builder->m_object = object;
      emit m_builder->objectCreated(object);

      // Optimization: Delete unused component now.
      m_builder->m_component->deleteLater();

      // Optimization: Delete unused incubator.
      m_builder->m_incubator = nullptr;
      delete this; // Very courageous but works.
    }
  }

private:
  AsyncObjectBuilder *m_builder;
};

// -----------------------------------------------------------------------------

AsyncObjectBuilder::AsyncObjectBuilder (QObject *parent) : QObject(parent) {}

AsyncObjectBuilder::~AsyncObjectBuilder () {
  delete m_incubator;
}

void AsyncObjectBuilder::createObject (QQmlEngine *engine, const char *path, Decorator decorator) {
  Q_ASSERT(!m_block_creation);
  #ifdef QT_DEBUG
    m_block_creation = true;
  #endif // ifdef QT_DEBUG

  m_component = new QQmlComponent(engine, QUrl(path), QQmlComponent::Asynchronous, this);
  m_decorator = decorator;

  qInfo() << QStringLiteral("Start async creation of: `%1`. Component:").arg(path) << m_component;

  QObject::connect(m_component, &QQmlComponent::statusChanged, this, &AsyncObjectBuilder::handleComponentCreation);
}

QObject *AsyncObjectBuilder::getObject () const {
  while (!m_object)
    QCoreApplication::processEvents(QEventLoop::AllEvents, 50);

  return m_object;
}

void AsyncObjectBuilder::handleComponentCreation (QQmlComponent::Status status) {
  if (status == QQmlComponent::Ready) {
    qInfo() << QStringLiteral("Component built:") << m_component;

    m_incubator = new ObjectIncubator(this);

    qInfo() << QStringLiteral("Start creation of component instance:") << m_component;

    m_component->create(*m_incubator);
  } else if (status == QQmlComponent::Error) {
    qWarning() << "AsyncObjectBuilder failed to build component:" << m_component->errors();
    abort();
  }
}
