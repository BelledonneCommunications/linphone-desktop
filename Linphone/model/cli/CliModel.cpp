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

#include "CliModel.hpp"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QObject>
#include <QSysInfo>
#include <QTimer>
#include <QUrl>

#include "model/core/CoreModel.hpp"
#include "model/tool/ToolModel.hpp"

// =============================================================================
DEFINE_ABSTRACT_OBJECT(CliModel)

std::shared_ptr<CliModel> CliModel::gCliModel;
QMap<QString, CliModel::Command> CliModel::mCommands{
    createCommand("show", QT_TR_NOOP("show_function_description"), &CliModel::cliShow, {}, true),
    createCommand("fetch-config", QT_TR_NOOP("fetch_config_function_description"), &CliModel::cliFetchConfig, {}, true),
    createCommand("call", QT_TR_NOOP("call_function_description"), &CliModel::cliCall, {{"sip-address", {}}}, true),
    createCommand("bye", QT_TR_NOOP("bye_function_description"), &CliModel::cliBye, {}, true),
    createCommand("accept", QT_TR_NOOP("accept_function_description"), &CliModel::cliAccept, {}, true),
    createCommand("decline", QT_TR_NOOP("decline_function_description"), &CliModel::cliDecline, {}, true),
    /*
    createCommand("initiate-conference", QT_TR_NOOP("initiateConferenceFunctionDescription"), cliInitiateConference, {
        { "sip-address", {} }, { "conference-id", {} }
    }),
    createCommand("join-conference", QT_TR_NOOP("joinConferenceFunctionDescription"), cliJoinConference, {
        { "sip-address", {} }, { "conference-id", {} }, { "display-name", {} }
    }),
    createCommand("join-conference-as", QT_TR_NOOP("joinConferenceAsFunctionDescription"), cliJoinConferenceAs, {
        { "sip-address", {} }, { "conference-id", {} }, { "guest-sip-address", {} }
    }),*/

};

std::pair<QString, CliModel::Command> CliModel::createCommand(const QString &functionName,
                                                              const char *functionDescription,
                                                              Function function,
                                                              const QHash<QString, Argument> &argsScheme,
                                                              const bool &genericArguments) {
	return {functionName.toLower(),
	        CliModel::Command(functionName.toLower(), functionDescription, function, argsScheme, genericArguments)};
}

CliModel::CliModel(QObject *parent) : QObject(parent) {
	moveToThread(CoreModel::getInstance()->thread());
}

CliModel::~CliModel() {
}

std::shared_ptr<CliModel> CliModel::create(QObject *parent) {
	auto model = std::make_shared<CliModel>(parent);
	// model->setSelf(model);
	return model;
}

std::shared_ptr<CliModel> CliModel::getInstance() {
	if (!gCliModel) gCliModel = CliModel::create(nullptr);
	return gCliModel;
}

// FIXME: Do not accept args without value like: cmd toto.
// In the future `toto` could be a boolean argument.
QRegularExpression
    CliModel::mRegExpArgs("(?:(?:([\\w-]+)\\s*)=\\s*(?:\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"|([^\\s]+)\\s*))");
QRegularExpression CliModel::mRegExpFunctionName("^\\s*([a-z-]+)\\s*");

QString CliModel::parseFunctionName(const QString &command, bool isOptional) {
	QRegularExpressionMatch match = mRegExpFunctionName.match(command.toLower());
	// mRegExpFunctionName.indexIn(command.toLower());
	// if (mRegExpFunctionName.pos(1) == -1) {
	if (!match.hasMatch()) {
		if (!isOptional) qWarning() << QStringLiteral("Unable to parse function name of command: `%1`.").arg(command);
		return QString("");
	}

	// const QStringList texts = mRegExpFunctionName.capturedTexts();
	const QStringList texts = match.capturedTexts();

	const QString functionName = texts[1];
	if (!mCommands.contains(functionName)) {
		if (!isOptional) qWarning() << QStringLiteral("This command doesn't exist: `%1`.").arg(functionName);
		return QString("");
	}

	return functionName;
}

QHash<QString, QString> CliModel::parseArgs(const QString &command) {
	QHash<QString, QString> args;
	int pos = 0;
	QRegularExpressionMatchIterator it = mRegExpArgs.globalMatch(command);
	while (it.hasNext()) {
		QRegularExpressionMatch match = it.next();
		if (match.hasMatch()) {
			args[match.captured(1)] = (match.captured(2).isEmpty() ? match.captured(3) : match.captured(2));
		}
	}
	return args;
}

void CliModel::cliShow(QHash<QString, QString> args) {
	emit showMainWindow();
}

void CliModel::cliFetchConfig(QHash<QString, QString> args) {
	if (args.contains("fetch-config")) {
		if (CoreModel::getInstance()->getCore()->getGlobalState() != linphone::GlobalState::On)
			connect(
			    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this,
			    [this, args]() { cliFetchConfig(args); }, Qt::SingleShotConnection);
		else CoreModel::getInstance()->useFetchConfig(args["fetch-config"]);
	}
}

void CliModel::cliCall(QHash<QString, QString> args) {
	if (args.contains("sip-address")) {
		if (!CoreModel::getInstance()->getCore() ||
		    CoreModel::getInstance()->getCore()->getGlobalState() != linphone::GlobalState::On)
			connect(
			    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this, [this, args]() { cliCall(args); },
			    Qt::SingleShotConnection);
		else ToolModel::createCall(args["sip-address"]);
	}
}

void CliModel::cliBye(QHash<QString, QString> args) {
	if (!CoreModel::getInstance()->getCore() ||
	    CoreModel::getInstance()->getCore()->getGlobalState() != linphone::GlobalState::On) {
		connect(
		    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this, [this, args]() { cliBye(args); },
		    Qt::SingleShotConnection);
		return;
	}

	if (args["sip-address"] == "*") // Call with options
		CoreModel::getInstance()->getCore()->terminateAllCalls();
	else if (args.size() == 0 || args["sip-address"] == "") {
		auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
		if (currentCall) currentCall->terminate();
		else lWarning() << log().arg("Cannot find a call to bye.");
	} else {
		auto address = ToolModel::interpretUrl(args["sip-address"]);
		auto currentCall = CoreModel::getInstance()->getCore()->getCallByRemoteAddress2(address);
		if (currentCall) currentCall->terminate();
		else lWarning() << log().arg("Cannot find a call to bye.");
	}
}

void CliModel::cliAccept(QHash<QString, QString> args) {
	if (!CoreModel::getInstance()->getCore() ||
	    CoreModel::getInstance()->getCore()->getGlobalState() != linphone::GlobalState::On) {
		connect(
		    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this, [this, args]() { cliBye(args); },
		    Qt::SingleShotConnection);
		return;
	}
	if (args.size() == 0 || args["sip-address"] == "" || args["sip-address"] == "*") {
		auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
		if (currentCall) currentCall->accept();
		else lWarning() << log().arg("Cannot find a call to accept.");
	} else {
		auto address = ToolModel::interpretUrl(args["sip-address"]);
		auto currentCall = CoreModel::getInstance()->getCore()->getCallByRemoteAddress2(address);
		if (currentCall) currentCall->accept();
		else lWarning() << log().arg("Cannot find a call to accept.");
	}
}

void CliModel::cliDecline(QHash<QString, QString> args) {
	if (!CoreModel::getInstance()->getCore() ||
	    CoreModel::getInstance()->getCore()->getGlobalState() != linphone::GlobalState::On) {
		connect(
		    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this, [this, args]() { cliBye(args); },
		    Qt::SingleShotConnection);
		return;
	}
	if (args.size() == 0 || args["sip-address"] == "" || args["sip-address"] == "*") {
		auto currentCall = CoreModel::getInstance()->getCore()->getCurrentCall();
		if (currentCall) currentCall->decline(linphone::Reason::Declined);
		else lWarning() << log().arg("Cannot find a call to decline.");
	} else {
		auto address = ToolModel::interpretUrl(args["sip-address"]);
		auto currentCall = CoreModel::getInstance()->getCore()->getCallByRemoteAddress2(address);
		if (currentCall) currentCall->decline(linphone::Reason::Declined);
		else lWarning() << log().arg("Cannot find a call to decline.");
	}
}

/*
QString CoreModel::getFetchConfig(QCommandLineParser *parser) {
    QString filePath = parser->value("fetch-config");
    bool error = false;
    filePath = getFetchConfig(filePath, &error);
    if (error) {
        qWarning() << "Remote provisionning cannot be retrieved. Command have beend cleaned";
        createParser();
    } else if (!filePath.isEmpty())
        mParser->process(
            cleanParserKeys(mParser, QStringList("fetch-config"))); // Remove this parameter from the parser
    return filePath;
}*/

//--------------------------------------------------------------------

CliModel::Command::Command(const QString &functionName,
                           const char *functionDescription,
                           CliModel::Function function,
                           const QHash<QString, CliModel::Argument> &argsScheme,
                           const bool &genericArguments)
    : mFunctionName(functionName), mFunctionDescription(functionDescription), mFunction(function),
      mArgsScheme(argsScheme), mGenericArguments(genericArguments) {
}

void CliModel::Command::execute(QHash<QString, QString> &args, CliModel *parent) {
	if (!mGenericArguments) { // Check arguments validity.
		for (const auto &argName : args.keys()) {
			if (!mArgsScheme.contains(argName)) {
				qWarning()
				    << QStringLiteral("Command with invalid argument: `%1 (%2)`.").arg(mFunctionName).arg(argName);

				return;
			}
		}
	}
	// Check missing arguments.
	for (const auto &argName : mArgsScheme.keys()) {
		if (!mArgsScheme[argName].isOptional && (!args.contains(argName) || args[argName].isEmpty())) {
			qWarning() << QStringLiteral("Missing argument for command: `%1 (%2)`.").arg(mFunctionName).arg(argName);
			return;
		}
	}
	qDebug() << "Execute";
	(parent->*mFunction)(args);
	/*
	    // Execute!
	    App *app = App::getInstance();
	    if (app->isOpened()) {
	        qInfo() << QStringLiteral("Execute command:") << args;
	        (*mFunction)(args);
	    } else {
	        Function f = mFunction;
	        QObject *context = new QObject();
	        QObject::connect(app, &App::opened, [f, args, context]() mutable {
	            if (context) {
	                delete context;
	                context = nullptr;
	                qInfo() << QStringLiteral("Execute deferred command:") << args;
	                QHash<QString, QString> fuckConst = args;
	                (*f)(fuckConst);
	            }
	        });
	    }
	    */
}

void CliModel::Command::executeUri(QString address, QHash<QString, QString> args, CliModel *parent) {
	QUrl url(address);
	QString query = url.query();

	QStringList parameters = query.split('&');
	for (int i = 0; i < parameters.size(); ++i) {
		QStringList parameter = parameters[i].split('=');
		if (parameter[0] != "" && parameter[0] != "method") {
			if (parameter.size() > 1) args[parameter[0]] = QByteArray::fromBase64(parameter[1].toUtf8());
			else args[parameter[0]] = "";
		}
	}

	args["sip-address"] = address;
	parent->addProcess(ProcessCommand(*this, args, 0, parent));
}

// pUrl can be `anytoken?p1=x&p2=y` or `p1=x&p2=y`. It will only use p1 and p2
void CliModel::Command::executeUrl(const QString &pUrl, CliModel *parent) {
	QHash<QString, QString> args;
	QStringList urlParts = pUrl.split('?');
	QString query = (urlParts.size() > 1 ? urlParts[1] : urlParts[0]);
	QString authority = (urlParts.size() > 1 && urlParts[0].contains(':') ? urlParts[0].split(':')[1] : "");

	QStringList parameters = query.split('&');
	for (int i = 0; i < parameters.size(); ++i) {
		QStringList parameter = parameters[i].split('=');
		if (parameter[0] != "method") {
			if (parameter.size() > 1) args[parameter[0]] = QByteArray::fromBase64(parameter[1].toUtf8());
			else args[parameter[0]] = "";
		}
	}
	if (!authority.isEmpty()) args["sip-address"] = authority;
	parent->addProcess(ProcessCommand(*this, args, 0, parent));
}

QString CliModel::Command::getFunctionSyntax() const {
	QString functionSyntax;
	functionSyntax += QStringLiteral("\"");
	functionSyntax += mFunctionName;
	for (auto &argName : mArgsScheme.keys()) {
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

//--------------------------------------------------------------------

void CliModel::executeCommand(const QString &command) { //, CommandFormat *format) {
	// Detect if command is a CLI by testing commands
	const QString &functionName = parseFunctionName(command, false);
	const QString configURI = QString(EXECUTABLE_NAME).toLower() + "-config";
	if (!functionName.isEmpty()) { // It is a CLI
		qInfo() << QStringLiteral("Detecting cli command: `%1`…").arg(command);
		QHash<QString, QString> args = parseArgs(command);
		QHash<QString, QString> argsToProcess;
		for (auto it = args.begin(); it != args.end(); ++it) {
			auto subfonction = parseFunctionName(it.key(), true);
			if (!subfonction.isEmpty()) {
				QHash<QString, QString> arg;
				arg[it.key()] = it.value();
				addProcess(ProcessCommand(mCommands[it.key()], arg, 1, this));
			} else {
				argsToProcess[it.key()] = it.value();
			}
		}
		addProcess(ProcessCommand(mCommands[functionName], argsToProcess, 0, this));
		// mCommands[functionName].execute(args, this);
		//  if (format) *format = CliFormat;
	} else { // It is a URI
		QStringList tempSipAddress = command.split(':');
		QString scheme = "sip";
		QString transformedCommand; // In order to pass bellesip parsing, set scheme to 'sip:'.
		if (tempSipAddress.size() == 1) {
			transformedCommand = "sip:" + command;
		} else {
			scheme = tempSipAddress[0].toLower();
			bool ok = false;
			for (const QString &validScheme :
			     {QString("sip"), "sip-" + QString(EXECUTABLE_NAME).toLower(), QString("sips"),
			      "sips-" + QString(EXECUTABLE_NAME).toLower(), QString(EXECUTABLE_NAME).toLower() + "-sip",
			      QString(EXECUTABLE_NAME).toLower() + "-sips", QString("tel"), QString("callto"), configURI})
				if (scheme == validScheme) ok = true;
			if (!ok) {
				qWarning()
				    << QStringLiteral("Not a valid URI: `%1` Unsupported scheme: `%2`.").arg(command).arg(scheme);
				return;
			}
			tempSipAddress[0] = "sip";
			transformedCommand = tempSipAddress.join(':');
		}
		if (scheme == configURI) {
			QHash<QString, QString> args = parseArgs(command);
			QString fetchUrl;
			if (args.contains("fetch-config")) fetchUrl = QByteArray::fromBase64(args["fetch-config"].toUtf8());
			else {
				QUrl url(command.mid(configURI.size() + 1)); // Remove 'exec-config:'
				if (url.scheme().isEmpty()) url.setScheme("https");
				fetchUrl = url.toString();
			}
			// if (format) *format = CliFormat;
			QHash<QString, QString> dummy;
			mCommands["show"].execute(dummy, this); // Just open the app.
			QHash<QString, QString> arg;
			arg["fetch-config"] = fetchUrl;
			addProcess(ProcessCommand(mCommands["fetch-config"], arg, 5, this));
		} else {
			std::shared_ptr<linphone::Address> address;
			QString qAddress = transformedCommand;
			if (Utils::isUsername(transformedCommand)) {
				address = linphone::Factory::get()->createAddress(
				    Utils::appStringToCoreString(transformedCommand + "@to.remove"));
				address->setDomain("");
				qAddress = Utils::coreStringToAppString(address->asString());
				if (address && qAddress.isEmpty()) qAddress = transformedCommand;
			} else
				address = linphone::Factory::get()->createAddress(
				    Utils::appStringToCoreString(transformedCommand)); // Test if command is an address
			// if (format) *format = UriFormat;
			qInfo() << QStringLiteral("Detecting URI command: `%1`…").arg(command);
			QString functionName;
			if (address) {
				functionName = Utils::coreStringToAppString(address->getHeader("method")).isEmpty()
				                   ? QStringLiteral("call")
				                   : Utils::coreStringToAppString(address->getHeader("method"));
			} else {
				QStringList fields = command.split('?');
				if (fields.size() > 1) {
					fields = fields[1].split('&');
					for (int i = 0; i < fields.size() && functionName.isEmpty(); ++i) {
						QStringList data = fields[i].split('=');
						if (data[0] == "method" && data.size() > 1) functionName = data[1];
					}
					if (functionName.isEmpty()) functionName = "call";
				}
			}
			functionName = functionName.toLower();
			if (functionName.isEmpty()) {
				qWarning() << QStringLiteral("There is no method set in `%1`.").arg(command);
				return;
			} else if (!mCommands.contains(functionName)) {
				qWarning() << QStringLiteral("This command doesn't exist: `%1`.").arg(functionName);
				return;
			}
			QHash<QString, QString> headers;
			if (address) {
				// TODO: check if there is too much headers.

				for (const auto &argName : mCommands[functionName].mArgsScheme.keys()) {
					const std::string header = address->getHeader(Utils::appStringToCoreString(argName));
					headers[argName] = QByteArray::fromBase64(QByteArray(header.c_str(), int(header.length())));
				}
				mCommands[functionName].executeUri(qAddress, headers, this);
			} else mCommands[functionName].executeUrl(command, this);
		}
	}
	runProcess();
}

void CliModel::addProcess(ProcessCommand process) {
	mQueue << process;
	std::sort(mQueue.begin(), mQueue.end(),
	          [](ProcessCommand &a, ProcessCommand &b) { return a.mPriority >= b.mPriority; });
}

void CliModel::runProcess() {
	if (mQueue.size() > 0) {
		lInfo() << log().arg("Processing command from queue");
		mQueue.first().run();
		mQueue.pop_front();
	} else lInfo() << log().arg("Queue is empty. Nothing to do.");
}

void CliModel::resetProcesses() {
	mQueue.clear();
}
