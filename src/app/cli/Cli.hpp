/*
 * Cli.hpp
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

#ifndef CLI_H_
#define CLI_H_

#include <memory>

#include <QHash>
#include <QObject>

// =============================================================================

namespace linphone {
  class Address;
}

class Cli : public QObject {
  Q_OBJECT;

  typedef void (*Function)(QHash<QString, QString> &);

  enum ArgumentType {
    STRING
  };

  struct Argument {
    Argument (ArgumentType type = STRING, bool isOptional = false) {
      this->type = type;
      this->isOptional = isOptional;
    }

    ArgumentType type;
    bool isOptional;
  };

  class Command {
  public:
    Command () = default;
    Command (
      const QString &functionName,
      const QString &functionDescription,
      const QString &cliDescription,
      Function function,
      const QHash<QString, Argument> &argsScheme
    );

    void execute (QHash<QString, QString> &args) const;
    void executeUri (const std::shared_ptr<linphone::Address> &address) const;

    QString getFunctionDescription() {
      return mFunctionDescription;
    }

    QString getCliDescription() {
      return mCliDescription;
    }


  private:
    QString mFunctionDescription;
    QString mCliDescription;
    QString mFunctionName;
    Function mFunction = nullptr;
    QHash<QString, Argument> mArgsScheme;
  };

public:
  Cli (QObject *parent = Q_NULLPTR);
  ~Cli () = default;

  enum CommandFormat {
    UnknownFormat,
    CliFormat,
    UriFormat
  };

  void executeCommand (const QString &command, CommandFormat *format = nullptr) const;

  void showHelp();

private:
  void addCommand (
    const QString &functionName,
    const QString &functionDescription,
    const QString &cliDescription,
    Function function,
    const QHash<QString, Argument> &argsScheme = QHash<QString, Argument>()
  );

  QString parseFunctionName (const QString &command) const;
  QHash<QString, QString> parseArgs (const QString &command) const;

  QHash<QString, Command> mCommands;

  static QRegExp mRegExpArgs;
  static QRegExp mRegExpFunctionName;
};

#endif // CLI_H_
