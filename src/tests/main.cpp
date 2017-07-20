/*
 * main.cpp
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
 *  Created on: July 17, 2017
 *      Author: Ronan Abhamon
 */

#include <QTest>
#include <QTimer>

#include "../app/AppController.hpp"
#include "../utils/Utils.hpp"

#include "assistant-view/AssistantViewTest.hpp"
#include "main-view/MainViewTest.hpp"
#include "self-test/SelfTest.hpp"

// =============================================================================

static QHash<QString, QObject *> initializeTests () {
  QHash<QString, QObject *> hash;
  hash["assistant-view"] = new AssistantViewTest();
  hash["main-view"] = new MainViewTest();
  return hash;
}

// -----------------------------------------------------------------------------

int main (int argc, char *argv[]) {
  int fakeArgc = 1;
  AppController controller(fakeArgc, argv);
  App *app = controller.getApp();
  if (app->isSecondary())
    qFatal("Unable to run test with secondary app.");

  int testsRet = 0;

  const QHash<QString, QObject *> tests = initializeTests();

  QObject *test = nullptr;
  if (argc > 1) {
    if (!strcmp(argv[1], "self-test"))
      // Execute only self-test.
      QTimer::singleShot(0, [app, &testsRet] {
        testsRet = QTest::qExec(new SelfTest(app));
        QCoreApplication::quit();
      });
    else {
      // Execute only one test.
      const QString testName = ::Utils::coreStringToAppString(argv[1]);
      test = tests[testName];
      if (!test) {
        qWarning() << QStringLiteral("Unable to run invalid test: `%1`.").arg(testName);
        return EXIT_FAILURE;
      }

      QTimer::singleShot(0, [app, &testsRet, test, argc, argv] {
        testsRet = QTest::qExec(new SelfTest(app));
        if (!testsRet)
          QTest::qExec(test, argc - 1, argv + 1);
        QCoreApplication::quit();
      });
    }
  } else
    // Execute all tests.
    QTimer::singleShot(0, [app, &testsRet, &tests] {
      testsRet = QTest::qExec(new SelfTest(app));
      if (!testsRet)
        for (const auto &test : tests) {
          testsRet |= QTest::qExec(test);
        }

      QCoreApplication::quit();
    });

  app->initContentApp();
  int ret = app->exec();

  for (auto &test : tests)
    delete test;

  if (testsRet)
    qWarning() << QStringLiteral("One or many tests are failed. :(");
  else
    qInfo() << QStringLiteral("Tests seems OK. :)");

  return testsRet || ret;
}
