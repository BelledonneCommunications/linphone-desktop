/*
 * Cli.cpp
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
 *  Created on: June 6, 2017
 *      Author: Nicolas Follet
 */

#include "../../components/core/CoreManager.hpp"
#include "../../utils/Utils.hpp"
#include "../App.hpp"

#include "Cli.hpp"

using namespace std;

// =============================================================================
// API.
// =============================================================================

static void cliShow (QHash<QString, QString> &) {
  App *app = App::getInstance();
  app->smartShowWindow(app->getMainWindow());
}

static void cliCall (QHash<QString, QString> &args) {
  CoreManager::getInstance()->getCallsListModel()->launchAudioCall(args["sip-address"]);
}

static void cliJoinConference (QHash<QString, QString> &args) {
  const QString sipAddress = args.take("sip-address");
  args["method"] = QStringLiteral("join-conference");
  CoreManager::getInstance()->getCallsListModel()->launchAudioCall(sipAddress, args);
}

static void cliInitiateConference (QHash<QString, QString> &args) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  // Check identity.
  {
    shared_ptr<linphone::Address> address = core->interpretSipAddress(::Utils::appStringToCoreString(args["sip-address"]));
    address->clean();

    const string sipAddress = address->asString();
    const string identity = core->getIdentity();
    if (sipAddress != identity) {
      qWarning() << QStringLiteral("Received different sip address from identity : `%1 != %2`.")
        .arg(::Utils::coreStringToAppString(identity))
        .arg(::Utils::coreStringToAppString(sipAddress));
      return;
    }
  }

  shared_ptr<linphone::Conference> conference = core->getConference();
  const QString id = args["conference-id"];

  if (conference) {
    if (conference->getId() == ::Utils::appStringToCoreString(id)) {
      qInfo() << QStringLiteral("Conference `%1` already exists.").arg(id);
      // TODO: Set the view to the "waiting call view".
      return;
    }

    qInfo() << QStringLiteral("Remove existing conference with id: `%1`.")
      .arg(::Utils::coreStringToAppString(conference->getId()));
    core->terminateConference();
  }

  qInfo() << QStringLiteral("Create conference with id: `%1`.").arg(id);
  conference = core->createConferenceWithParams(core->createConferenceParams());
  conference->setId(::Utils::appStringToCoreString(id));

  if (core->enterConference() == -1) {
    qWarning() << QStringLiteral("Unable to join created conference: `%1`.").arg(id);
    return;
  }

  // TODO: Set the view to the "waiting call view".
}

// =============================================================================

Cli::Command::Command (
  const QString &functionName,
  const QString &description,
  Cli::Function function,
  const QHash<QString, Cli::Argument> &argsScheme
) :
  mFunctionName(functionName),
  mDescription(description),
  mFunction(function),
  mArgsScheme(argsScheme) {}

void Cli::Command::execute (QHash<QString, QString> &args) const {
  // Check arguments validity.
  for (const auto &argName : args.keys()) {
    if (!mArgsScheme.contains(argName)) {
      qWarning() << QStringLiteral("Command with invalid argument: `%1 (%2)`.")
        .arg(mFunctionName).arg(argName);

      return;
    }
  }

  // Check missing arguments.
  for (const auto &argName : mArgsScheme.keys()) {
    if (!args.contains(argName) && !mArgsScheme[argName].isOptional) {
      qWarning() << QStringLiteral("Missing argument for command: `%1 (%2)`.")
        .arg(mFunctionName).arg(argName);
      return;
    }
  }

  // Execute!
  CoreManager *coreManager = CoreManager::getInstance();

  if (coreManager->started())
    (*mFunction)(args);
  else {
    Function f = mFunction;
    ::Utils::connectOnce(coreManager->getHandlers().get(), &CoreHandlers::coreStarted, coreManager, [f, args] {
      QHash<QString, QString> fuckConst = args;
      (*f)(fuckConst);
    });
  }
}

void Cli::Command::executeUri (const shared_ptr<linphone::Address> &address) const {
  QHash<QString, QString> args;
  for (const auto &argName : mArgsScheme.keys())
    args[argName] = ::Utils::coreStringToAppString(address->getHeader(::Utils::appStringToCoreString(argName)));
  args["sip-address"] = ::Utils::coreStringToAppString(address->asString());

  execute(args);
}

// =============================================================================

// FIXME: Do not accept args without value like: cmd toto.
// In the future `toto` could be a boolean argument.
QRegExp Cli::mRegExpArgs("(?:(?:([\\w-]+)\\s*)=\\s*(?:\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"|([^\\s]+)\\s*))");
QRegExp Cli::mRegExpFunctionName("^\\s*([a-z-]+)\\s*");

Cli::Cli (QObject *parent) : QObject(parent) {
  addCommand("show", tr("showFunctionDescription"), ::cliShow);
  addCommand("call", tr("showFunctionCall"), ::cliCall, {
    { "sip-address", {} }
  });
  addCommand("initiate-conference", tr("initiateConferenceFunctionDescription"), ::cliInitiateConference, {
    { "sip-address", {} }, { "conference-id", {} }
  });
  addCommand("join-conference", tr("joinConferenceFunctionDescription"), ::cliJoinConference, {
    { "sip-address", {} }, { "conference-id", {} }
  });
}

// -----------------------------------------------------------------------------

void Cli::addCommand (
  const QString &functionName,
  const QString &description,
  Function function,
  const QHash<QString, Argument> &argsScheme
) {
  if (mCommands.contains(functionName))
    qWarning() << QStringLiteral("Command already exists: `%1`.").arg(functionName);
  else
    mCommands[functionName] = Cli::Command(functionName, description, function, argsScheme);
}

// -----------------------------------------------------------------------------

void Cli::executeCommand (const QString &command) const {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
      ::Utils::appStringToCoreString(command)
    );

  // Execute cli command.
  if (!address) {
    const QString &functionName = parseFunctionName(command);
    if (!functionName.isEmpty()) {
      QHash<QString, QString> args = parseArgs(command);
      mCommands[functionName].execute(args);
    }

    return;
  }

  // Execute uri command.
  string scheme = address->getScheme();
  if (address->getUsername().empty() || (scheme != "sip" && scheme != "sip-linphone")) {
    qWarning() << QStringLiteral("Not a valid uri: `%1`.").arg(command);
    return;
  }

  const QString functionName = ::Utils::coreStringToAppString(address->getHeader("method")).isEmpty()
    ? QStringLiteral("call")
    : ::Utils::coreStringToAppString(address->getHeader("method"));

  if (!functionName.isEmpty() && !mCommands.contains(functionName)) {
    qWarning() << QStringLiteral("This command doesn't exist: `%1`.").arg(functionName);
    return;
  }

  mCommands[functionName].executeUri(address);
}

// -----------------------------------------------------------------------------

QString Cli::parseFunctionName (const QString &command) const {
  mRegExpFunctionName.indexIn(command);
  if (mRegExpFunctionName.pos(1) == -1) {
    qWarning() << QStringLiteral("Unable to parse function name of command: `%1`.").arg(command);
    return QString("");
  }

  const QStringList texts = mRegExpFunctionName.capturedTexts();

  const QString functionName = texts[1];
  if (!mCommands.contains(functionName)) {
    qWarning() << QStringLiteral("This command doesn't exist: `%1`.").arg(functionName);
    return QString("");
  }

  return functionName;
}

QHash<QString, QString> Cli::parseArgs (const QString &command) const {
  QHash<QString, QString> args;
  int pos = 0;

  while ((pos = mRegExpArgs.indexIn(command, pos)) != -1) {
    pos += mRegExpArgs.matchedLength();
    args[mRegExpArgs.cap(1)] = (mRegExpArgs.cap(2).isEmpty() ? mRegExpArgs.cap(3) : mRegExpArgs.cap(2));
  }

  return args;
}
