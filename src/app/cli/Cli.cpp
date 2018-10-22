/*
 * Cli.cpp
 * Copyright (C) 2017-2018  Belledonne Communications, Grenoble, France
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

#include <iostream>

#include <QQuickWindow>

#include "config.h"

#include "app/App.hpp"
#include "components/calls/CallsListModel.hpp"
#include "components/core/CoreHandlers.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Utils.hpp"

#include "Cli.hpp"

// =============================================================================

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

  CoreManager *coreManager = CoreManager::getInstance();
  const shared_ptr<linphone::Core> core = coreManager->getCore();

  {
    shared_ptr<linphone::Address> address = core->createPrimaryContactParsed();
    address->setDisplayName(Utils::appStringToCoreString(args.take("display-name")));
    core->setPrimaryContact(address->asString());
  }

  args["method"] = QStringLiteral("join-conference");
  coreManager->getCallsListModel()->launchAudioCall(sipAddress, args);
}

static void cliJoinConferenceAs (QHash<QString, QString> &args) {
  const QString fromSipAddress = args.take("guest-sip-address");
  const QString toSipAddress = args.take("sip-address");
  CoreManager *coreManager = CoreManager::getInstance();
  shared_ptr<linphone::ProxyConfig> proxyConfig = coreManager->getCore()->getDefaultProxyConfig();

  if (!proxyConfig) {
    qWarning() << QStringLiteral("You have no proxy config.");
    return;
  }

  const shared_ptr<const linphone::Address> currentSipAddress = proxyConfig->getIdentityAddress();
  const shared_ptr<const linphone::Address> askedSipAddress = linphone::Factory::get()->createAddress(
    Utils::appStringToCoreString(fromSipAddress)
  );
  if (!currentSipAddress->weakEqual(askedSipAddress)) {
    qWarning() << QStringLiteral("Guest sip address `%1` doesn't match with default proxy config.")
      .arg(fromSipAddress);
    return;
  }

  args["method"] = QStringLiteral("join-conference");
  coreManager->getCallsListModel()->launchAudioCall(toSipAddress, args);
}

static void cliInitiateConference (QHash<QString, QString> &args) {
  shared_ptr<linphone::Core> core = CoreManager::getInstance()->getCore();

  // Check identity.
  {
    shared_ptr<linphone::Address> address = core->interpretUrl(Utils::appStringToCoreString(args["sip-address"]));
    if (!address || address->getUsername().empty()) {
      qWarning() << QStringLiteral("Unable to parse invalid sip address.");
      return;
    }

    address->clean();

    shared_ptr<linphone::ProxyConfig> proxyConfig = core->getDefaultProxyConfig();
    if (!proxyConfig) {
      qWarning() << QStringLiteral("Not connected to a proxy config");
      return;
    }
    if (!proxyConfig->getIdentityAddress()->weakEqual(address)) {
      qWarning() << QStringLiteral("Received different sip address from identity : `%1 != %2`.")
        .arg(Utils::coreStringToAppString(proxyConfig->getIdentityAddress()->asString()))
        .arg(Utils::coreStringToAppString(address->asString()));
      return;
    }
  }

  shared_ptr<linphone::Conference> conference = core->getConference();
  const QString id = args["conference-id"];

  auto updateCallsWindow = []() {
    QQuickWindow *callsWindow = App::getInstance()->getCallsWindow();
    if (!callsWindow)
      return;

    // TODO: Set the view to the "waiting call view".
    if (CoreManager::getInstance()->getSettingsModel()->getKeepCallsWindowInBackground()) {
      if (!callsWindow->isVisible())
        callsWindow->showMinimized();
    } else
      App::smartShowWindow(callsWindow);
  };

  if (conference) {
    if (conference->getId() == Utils::appStringToCoreString(id)) {
      qInfo() << QStringLiteral("Conference `%1` already exists.").arg(id);
      updateCallsWindow();
      return;
    }

    qInfo() << QStringLiteral("Remove existing conference with id: `%1`.")
      .arg(Utils::coreStringToAppString(conference->getId()));
    core->terminateConference();
  }

  qInfo() << QStringLiteral("Create conference with id: `%1`.").arg(id);
  conference = core->createConferenceWithParams(core->createConferenceParams());
  conference->setId(Utils::appStringToCoreString(id));

  if (core->enterConference() == -1) {
    qWarning() << QStringLiteral("Unable to join created conference: `%1`.").arg(id);
    return;
  }

  updateCallsWindow();
}

// =============================================================================
// Helpers.
// =============================================================================

static QString splitWord (QString word, int &curPos, const int lineLength, const QString &padding) {
  QString out;
  out += word.mid(0, lineLength - curPos) + "\n" + padding;
  curPos = padding.length();
  word = word.mid(lineLength - curPos);
  while (word.length() > lineLength - curPos) {
    out += word.mid(0, lineLength - curPos);
    word = word.mid(lineLength - curPos);
    out += "\n" + padding;
  }
  out += word;
  curPos = word.length() + padding.length();
  return out;
}

static QString indentedWord (QString word, int &curPos, const int lineLength, const QString &padding) {
  QString out;
  if (curPos + word.length() > lineLength) {
    if (padding.length() + word.length() > lineLength) {
      out += splitWord(word, curPos, lineLength, padding);
    } else {
      out += QStringLiteral("\n");
      out += padding + word;
      curPos = padding.length();
    }
  } else {
    out += word;
    curPos += word.length();
  }
  return out;
}

static string multilineIndent (const QString &str, int indentationNumber = 0) {
  constexpr int lineLength(80);

  static const QRegExp spaceRegexp("(\\s)");
  const QString padding(indentationNumber * 2, ' ');

  QString out = padding;

  int indentedTextCurPos = padding.length();

  int spacePos = 0;
  int wordPos = spacePos;
  QString word;

  while ((spacePos = spaceRegexp.indexIn(str, spacePos)) != -1) {
    word = str.mid(wordPos, spacePos - wordPos);
    out += indentedWord(word, indentedTextCurPos, lineLength, padding);
    switch (str[spacePos].unicode()) {
      case '\n':
        out += "\n" + padding;
        indentedTextCurPos = padding.length();
        break;
      case '\t': // TAB as space.
      case ' ':
        if (indentedTextCurPos == lineLength) {
          out += "\n" + padding;
          indentedTextCurPos = padding.length();
        } else {
          out += " ";
          indentedTextCurPos += 1;
        }
        break;

      default:
        break;
    }
    spacePos += 1;
    wordPos = spacePos;
  }
  word = str.mid(wordPos);
  out += indentedWord(word, indentedTextCurPos, lineLength, padding);
  out += "\n";

  return Utils::appStringToCoreString(out);
}

// =============================================================================

Cli::Command::Command (
  const QString &functionName,
  const char *functionDescription,
  Cli::Function function,
  const QHash<QString, Cli::Argument> &argsScheme
) :
  mFunctionName(functionName),
  mFunctionDescription(functionDescription),
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
    if (!mArgsScheme[argName].isOptional && (!args.contains(argName) || args[argName].isEmpty())) {
      qWarning() << QStringLiteral("Missing argument for command: `%1 (%2)`.")
        .arg(mFunctionName).arg(argName);
      return;
    }
  }

  // Execute!
  App *app = App::getInstance();
  if (app->isOpened()) {
    qInfo() << QStringLiteral("Execute command:") << args;
    (*mFunction)(args);
  } else {
    Function f = mFunction;
    Utils::connectOnce(app, &App::opened, app, [f, args] {
      qInfo() << QStringLiteral("Execute deferred command:") << args;
      QHash<QString, QString> fuckConst = args;
      (*f)(fuckConst);
    });
  }
}

void Cli::Command::executeUri (const shared_ptr<linphone::Address> &address) const {
  QHash<QString, QString> args;
  // TODO: check if there is too much headers.
  for (const auto &argName : mArgsScheme.keys()) {
    const string header = address->getHeader(Utils::appStringToCoreString(argName));
    args[argName] = QByteArray::fromBase64(QByteArray(header.c_str(), int(header.length())));
  }
  address->clean();
  args["sip-address"] = Utils::coreStringToAppString(address->asStringUriOnly());
  execute(args);
}

QString Cli::Command::getFunctionSyntax () const {
  QString functionSyntax;
  functionSyntax += QStringLiteral("\"");
  functionSyntax += mFunctionName;
  for (auto &argName : mArgsScheme.keys()){
    functionSyntax += QStringLiteral(" ");
    functionSyntax += mArgsScheme[argName].isOptional ? QStringLiteral("[") : QStringLiteral("");
    functionSyntax += argName;
    functionSyntax += QStringLiteral("=<");
    switch (mArgsScheme[argName].type) {
      case String:
        functionSyntax += QStringLiteral("str");
        break;
      default:
        functionSyntax += QStringLiteral("value");
        break;
    }
    functionSyntax += QString(">");
    functionSyntax += mArgsScheme[argName].isOptional ? QStringLiteral("]") : QStringLiteral("");
  }
  functionSyntax += QStringLiteral("\"");
  return functionSyntax;
}

// =============================================================================

// FIXME: Do not accept args without value like: cmd toto.
// In the future `toto` could be a boolean argument.
QRegExp Cli::mRegExpArgs("(?:(?:([\\w-]+)\\s*)=\\s*(?:\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"|([^\\s]+)\\s*))");
QRegExp Cli::mRegExpFunctionName("^\\s*([a-z-]+)\\s*");

QMap<QString, Cli::Command> Cli::mCommands = {
  createCommand("show", QT_TR_NOOP("showFunctionDescription"), cliShow),
  createCommand("call", QT_TR_NOOP("callFunctionDescription"), cliCall, {
    { "sip-address", {} }
  }),
  createCommand("initiate-conference", QT_TR_NOOP("initiateConferenceFunctionDescription"), cliInitiateConference, {
    { "sip-address", {} }, { "conference-id", {} }
  }),
  createCommand("join-conference", QT_TR_NOOP("joinConferenceFunctionDescription"), cliJoinConference, {
    { "sip-address", {} }, { "conference-id", {} }, { "display-name", {} }
  }),
  createCommand("join-conference-as", QT_TR_NOOP("joinConferenceAsFunctionDescription"), cliJoinConferenceAs, {
    { "sip-address", {} }, { "conference-id", {} }, { "guest-sip-address", {} }
  })
};

// -----------------------------------------------------------------------------

void Cli::executeCommand (const QString &command, CommandFormat *format) {
  shared_ptr<linphone::Address> address = linphone::Factory::get()->createAddress(
    Utils::appStringToCoreString(command)
  );

  // Execute cli command.
  if (!address) {
    qInfo() << QStringLiteral("Detecting cli command: `%1`...").arg(command);

    const QString &functionName = parseFunctionName(command);
    if (!functionName.isEmpty()) {
      QHash<QString, QString> args = parseArgs(command);
      mCommands[functionName].execute(args);
    }

    if (format)
      *format = CliFormat;

    return;
  }

  if (format)
    *format = UriFormat;

  // Execute uri command.
  qInfo() << QStringLiteral("Detecting uri command: `%1`...").arg(command);

  if (address->getUsername().empty()) {
    qWarning() << QStringLiteral("Failed to execute command. No username given.");
    return;
  }

  string scheme = address->getScheme();
  for (const string &validScheme : { "sip", "sip-linphone", "sips", "sips-linphone" })
    if (scheme == validScheme)
      goto success;
  qWarning() << QStringLiteral("Not a valid uri: `%1` Unsupported scheme: `%2`.")
    .arg(command).arg(Utils::coreStringToAppString(scheme));
  return;

success:
  const QString functionName = Utils::coreStringToAppString(address->getHeader("method")).isEmpty()
    ? QStringLiteral("call")
    : Utils::coreStringToAppString(address->getHeader("method"));

  if (!functionName.isEmpty() && !mCommands.contains(functionName)) {
    qWarning() << QStringLiteral("This command doesn't exist: `%1`.").arg(functionName);
    return;
  }

  mCommands[functionName].executeUri(address);
}

void Cli::showHelp () {
  cout << multilineIndent(tr("appCliDescription").arg(APPLICATION_NAME), 0) <<
    endl <<
    "Usage: " <<
    endl <<
    multilineIndent(tr("uriCommandLineSyntax").arg(EXECUTABLE_NAME), 0) <<
    multilineIndent(tr("cliCommandLineSyntax").arg(EXECUTABLE_NAME), 0) <<
    endl <<
    multilineIndent(tr("commandsName")) << endl;

  for (const auto &method : mCommands.keys())
    cout << multilineIndent(mCommands[method].getFunctionSyntax(), 1) <<
      multilineIndent(tr(mCommands[method].getFunctionDescription()), 2) <<
      endl;
}

// -----------------------------------------------------------------------------

pair<QString, Cli::Command> Cli::createCommand (
  const QString &functionName,
  const char *functionDescription,
  Function function,
  const QHash<QString, Argument> &argsScheme
) {
  return { functionName, Cli::Command(functionName, functionDescription, function, argsScheme) };
}

// -----------------------------------------------------------------------------

QString Cli::parseFunctionName (const QString &command) {
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

QHash<QString, QString> Cli::parseArgs (const QString &command) {
  QHash<QString, QString> args;
  int pos = 0;

  while ((pos = mRegExpArgs.indexIn(command, pos)) != -1) {
    pos += mRegExpArgs.matchedLength();
    args[mRegExpArgs.cap(1)] = (mRegExpArgs.cap(2).isEmpty() ? mRegExpArgs.cap(3) : mRegExpArgs.cap(2));
  }

  return args;
}
