/*
 * Copyright (c) 2010-2024 Belledonne Communications SARL.
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

#ifndef CLI_MODEL_H_
#define CLI_MODEL_H_

#include <QObject>
#include <QRegularExpression>
#include <QSharedPointer>
#include <QString>
#include <QThread>
#include <linphone++/linphone.hh>

#include "tool/AbstractObject.hpp"

// =============================================================================

class CliModel : public QObject, public AbstractObject {
	Q_OBJECT
public:
	CliModel(QObject *parent);
	~CliModel();
	static std::shared_ptr<CliModel> create(QObject *parent);
	static std::shared_ptr<CliModel> getInstance();

	QString parseFunctionName(const QString &command, bool isOptional);
	QHash<QString, QString> parseArgs(const QString &command);

	void cliShow(QHash<QString, QString> args);
	void cliFetchConfig(QHash<QString, QString> args);
	void cliCall(QHash<QString, QString> args);
	void cliBye(QHash<QString, QString> args);
	void cliAccept(QHash<QString, QString> args);
	void cliDecline(QHash<QString, QString> args);

	static QRegularExpression mRegExpArgs;
	static QRegularExpression mRegExpFunctionName;

	enum ArgumentType { String };

	typedef void (CliModel::*Function)(QHash<QString, QString>);
	struct Argument {
		Argument(ArgumentType type = String, bool isOptional = false) {
			this->type = type;
			this->isOptional = isOptional;
		}

		ArgumentType type;
		bool isOptional;
	};
	class Command {
	public:
		Command() = default;
		Command(const Command &command) = default;
		Command(const QString &functionName,
		        const char *functionDescription,
		        Function function,
		        const QHash<QString, Argument> &argsScheme,
		        const bool &genericArguments = false);

		void execute(QHash<QString, QString> &args, CliModel *parent);
		void executeUri(QString address, QHash<QString, QString> args, CliModel *parent);
		void executeUrl(const QString &url, CliModel *parent);

		const char *getFunctionDescription() const {
			return mFunctionDescription;
		}

		QString getFunctionSyntax() const;

		QHash<QString, Argument> mArgsScheme;

	private:
		QString mFunctionName;
		const char *mFunctionDescription;
		Function mFunction = nullptr;
		bool mGenericArguments = false; // Used to avoid check on arguments
	};
	static QMap<QString, Command> mCommands;

	class ProcessCommand : public Command {
	public:
		ProcessCommand(Command command, QHash<QString, QString> args, int priority, CliModel *parent)
		    : Command(command), mArguments(args), mPriority(priority), mParent(parent) {
		}
		bool operator<(const ProcessCommand &item) {
			return mPriority < item.mPriority;
		}
		void run() {
			execute(mArguments, mParent);
		}
		int mPriority = 0;
		CliModel *mParent;
		QHash<QString, QString> mArguments;
	};

	QList<ProcessCommand> mQueue;
	void addProcess(ProcessCommand); // Add and sort
	void runProcess();
	void resetProcesses();

	static std::pair<QString, Command>
	createCommand(const QString &functionName,
	              const char *functionDescription,
	              Function function,
	              const QHash<QString, Argument> &argsScheme = QHash<QString, Argument>(),
	              const bool &genericArguments = false);

	enum CommandFormat {
		UnknownFormat,
		CliFormat,
		UriFormat, // Parameters are in base64
		UrlFormat
	};

	void executeCommand(const QString &command);
signals:
	void showMainWindow();

private:
	static std::shared_ptr<CliModel> gCliModel;
	DECLARE_ABSTRACT_OBJECT
};

#endif
