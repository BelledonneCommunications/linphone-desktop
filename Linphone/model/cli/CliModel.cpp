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

QByteArray decodeBase64Url(QString input) {
	QUrl url(input);
	// if url is not encoded return it as it is
	if (url.isValid() && !url.scheme().isEmpty()) {
		return QUrl::fromPercentEncoding(input.toUtf8()).toUtf8();
	}
	return QByteArray::fromBase64(input.toUtf8());
}

const QString deprecatedConfigURI = QString(EXECUTABLE_NAME).toLower() + "-config";
QStringList validSchemes = {QString("sip"),
                            "sip-" + QString(EXECUTABLE_NAME).toLower(),
                            QString("sips"),
                            "sips-" + QString(EXECUTABLE_NAME).toLower(),
                            QString(EXECUTABLE_NAME).toLower() + "-sip",
                            QString(EXECUTABLE_NAME).toLower() + "-sips",
                            QString("tel"),
                            QString("callto"),
                            deprecatedConfigURI};

QStringList deprecatedSchemes = {"sips-" + QString(EXECUTABLE_NAME).toLower(), deprecatedConfigURI};

QMap<QString, CliModel::Command> CliModel::mCommands{
    createCommand("show", QT_TR_NOOP("show_function_description"), &CliModel::cliShow, {}, true),
    createCommand("fetch-config", QT_TR_NOOP("fetch_config_function_description"), &CliModel::cliFetchConfig, {}, true),
    createCommand("call", QT_TR_NOOP("call_function_description"), &CliModel::cliCall, {{"sip-address", {}}}, true),
    createCommand("bye", QT_TR_NOOP("bye_function_description"), &CliModel::cliBye, {}, true),
    createCommand("accept", QT_TR_NOOP("accept_function_description"), &CliModel::cliAccept, {}, true),
    createCommand("decline", QT_TR_NOOP("decline_function_description"), &CliModel::cliDecline, {}, true),
    createCommand("use-sips", QT_TR_NOOP("use_sips_function_description"), &CliModel::cliUseSips, {}, true),
    /*
    createCommand("initiate-conference", QT_TR_NOOP("initiateConferenceFunctionDescription"), cliInitiateConference,
    { { "sip-address", {} }, { "conference-id", {} }
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
    CliModel::mRegExpArgs("(?:(?:([\\w-]+)\\s*)(?:=|\\s)(?:\"([^\"\\\\]*(?:\\\\.[^\"\\\\]*)*)\"|([^\\s]+)\\s*))");
QRegularExpression CliModel::mRegExpFunctionName("^\\s*([a-z-]+)\\s*");

QString CliModel::parseFunctionName(const QString &command, bool isOptional) {
	QRegularExpressionMatch match = mRegExpFunctionName.match(command.toLower());
	// mRegExpFunctionName.indexIn(command.toLower());
	// if (mRegExpFunctionName.pos(1) == -1) {
	if (!match.hasMatch()) {
		if (!isOptional) lWarning() << QStringLiteral("Unable to parse function name of command: `%1`.").arg(command);
		return QString("");
	}

	// const QStringList texts = mRegExpFunctionName.capturedTexts();
	const QStringList texts = match.capturedTexts();

	QString functionName = texts[1];
	const QString functionKey = texts[0];
	if (!mCommands.contains(functionName)) {
		if (!isOptional) lWarning() << QStringLiteral("This command doesn't exist: `%1`.").arg(functionName);
		return QString("");
	}

	lDebug() << QStringLiteral("Function parsed : %1").arg(functionName);
	return functionName;
}

QHash<QString, QString> CliModel::parseArgs(const QString &command) {
	QHash<QString, QString> args;
	int pos = 0;
	QRegularExpressionMatchIterator it = mRegExpArgs.globalMatch(command);
	while (it.hasNext()) {
		QRegularExpressionMatch match = it.next();
		if (match.hasMatch()) {
			lInfo() << "arg parsed" << match.captured(1)
			        << (match.captured(2).isEmpty() ? match.captured(3) : match.captured(2));
			args[match.captured(1)] = (match.captured(2).isEmpty() ? match.captured(3) : match.captured(2));
		}
	}
	return args;
}

void CliModel::cliShow(QHash<QString, QString> args) {
	emit showMainWindow();
}

void CliModel::cliFetchConfig(QHash<QString, QString> args) {
	lInfo() << "Execute fetch-config with arg" << args["fetch-config"];
	if (args["fetch-config"].isEmpty()) {
		lWarning() << "Fetch config has no url to process, return";
		return;
	}
	if (args.contains("fetch-config")) {
		if (CoreModel::getInstance()->getCore()->getGlobalState() != linphone::GlobalState::On)
			connect(
			    CoreModel::getInstance().get(), &CoreModel::globalStateChanged, this,
			    [this, args]() { cliFetchConfig(args); }, Qt::SingleShotConnection);
		else CoreModel::getInstance()->useFetchConfig(args["fetch-config"], false);
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

void CliModel::cliUseSips(QHash<QString, QString> args) {
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
			qWarning() << QStringLiteral("Missing argument for command: '%1' (%2).").arg(mFunctionName).arg(argName);
			return;
		}
	}
	qDebug() << "Execute" << mFunctionName;
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
	lInfo() << QStringLiteral("CliModel : execute uri : %1").arg(query);

	QStringList parameters = query.split('&');
	for (int i = 0; i < parameters.size(); ++i) {
		QStringList parameter = parameters[i].split('=');
		lDebug() << QStringLiteral("CliModel : Detecting parameter : %1").arg(parameter[0]);
		QHash<QString, QString> args = parent->parseArgs(parameters[i]);
		for (auto it = args.begin(); it != args.end(); ++it) {
			qDebug() << "process arg" << it.key() << it.value();
			auto subfonction = parent->parseFunctionName(it.key(), true);
			qDebug() << "subfonction" << subfonction;
			if (!subfonction.isEmpty()) {
				QHash<QString, QString> arg;
				arg[it.key()] = decodeBase64Url(it.value());
				lDebug() << "parsing parameters" << it.key() << it.value();
				parent->addProcess(ProcessCommand(mCommands[it.key()], arg, 1, parent));
			}
		}
	}

	QString sipAddress = address.left(address.indexOf('?'));
	// We need to remove "sip:" in order to obtain an url with
	// the domain as a suffix (interpretUrl will return the address as it is
	// if starting by "sip:")
	if (sipAddress.startsWith("sip:")) sipAddress.remove("sip:");
	auto linphoneAddress = ToolModel::interpretUrl(sipAddress);
	lInfo() << "CliModel: getting sip address " << (linphoneAddress ? linphoneAddress->asStringUriOnly() : "null !");
	if (linphoneAddress) {
		args["sip-address"] = Utils::coreStringToAppString(linphoneAddress->asStringUriOnly());
		parent->addProcess(ProcessCommand(*this, args, 0, parent));
	} else {
		lWarning() << "CliModel: Could not get sip address from" << args["sip-address"] << "; not adding process";
	}
}

// pUrl can be `anytoken?p1=x&p2=y` or `p1=x&p2=y`. It will only use p1 and p2
void CliModel::Command::executeUrl(const QString &pUrl, CliModel *parent) {
	QHash<QString, QString> args;
	QStringList urlParts = pUrl.split('?');
	QString query = (urlParts.size() > 1 ? urlParts[1] : urlParts[0]);
	QString authority = (urlParts.size() > 1 && urlParts[0].contains(':') ? urlParts[0].split(':')[1] : "");
	lDebug() << QStringLiteral("CliModel : execute url : %1").arg(query);

	QStringList parameters = query.split('&');
	for (int i = 0; i < parameters.size(); ++i) {
		QStringList parameter = parameters[i].split('=');
		lDebug() << QStringLiteral("CliModel : Detecting parameter : %1").arg(parameter[0]);
		QHash<QString, QString> args = parent->parseArgs(parameters[i]);
		for (auto it = args.begin(); it != args.end(); ++it) {
			QString functionName = it.key();
			if (functionName.startsWith(QString(EXECUTABLE_NAME).toLower() + "-"))
				functionName.remove(QString(EXECUTABLE_NAME).toLower() + "-");
			lDebug() << "Find function in" << it.key() << it.value();
			auto subfonction = parent->parseFunctionName(functionName, true);
			if (!subfonction.isEmpty()) {
				QHash<QString, QString> arg;
				arg[functionName] = decodeBase64Url(it.value());
				lDebug() << "parsing parameters" << functionName << it.value();
				parent->addProcess(ProcessCommand(mCommands[functionName], arg, 1, parent));
			}
		}
	}
	if (!authority.isEmpty())
		args["sip-address"] = Utils::coreStringToAppString(ToolModel::interpretUrl(authority)->asStringUriOnly());
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

void CliModel::executeCommand(QString command) { //, CommandFormat *format) {
	// Detect if command is a CLI by testing commands
	const QString &functionName = parseFunctionName(command, false);
	if (!functionName.isEmpty()) { // It is a CLI
		lInfo() << log().arg("Detecting cli command: `%1`…").arg(command);
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
		if (command.startsWith("sip:") || command.startsWith("sips:")) {
			auto query = command.split('?');
			if (query.size() > 1 && !query[1].isEmpty()) {
				lWarning() << log().arg("sip and sips scheme does not take arguments into account anymore. Use sip-" +
				                        QString(EXECUTABLE_NAME).toLower() + " instead.");
				command = query[0];
				lInfo() << "Command has been reduced to " << command;
			}
		}
		QStringList tempSipAddress = command.split(':');
		QString scheme = "sip";
		QString transformedCommand; // In order to pass bellesip parsing, set scheme to 'sip:'.
		if (tempSipAddress.size() == 1) {
			transformedCommand = "sip:" + command;
		} else {
			scheme = tempSipAddress[0].toLower();
			bool ok = false;
			lInfo() << log().arg("Using scheme %1").arg(scheme);
			for (const QString &validScheme : validSchemes)
				if (scheme == validScheme) {
					ok = true;
					break;
				}
			if (!ok) {
				qWarning()
				    << QStringLiteral("Not a valid URI: `%1` Unsupported scheme: `%2`.").arg(command).arg(scheme);
				Utils::showInformationPopup("info_popup_error_title",
				                            //: "Not a valid URI: `%1` Unsupported scheme: `%2`."
				                            tr("info_popup_cli_unsupported_scheme_message").arg(command).arg(scheme),
				                            false);
				return;
			}
			bool deprecated = false;
			for (const QString &deprecatedScheme : deprecatedSchemes)
				if (scheme == deprecatedScheme) {
					deprecated = true;
					break;
				}
			if (deprecated) {
				lWarning() << scheme
				           << "is deprecated. It will be removed in a further version. Use sip-" +
				                  QString(EXECUTABLE_NAME).toLower()
				           << "instead.";
			}
			tempSipAddress[0] = "sip";
			transformedCommand = tempSipAddress.join(':');
		}
		if (scheme == deprecatedConfigURI) {
			lWarning() << scheme
			           << "is deprecated and will be removed in a further version. Please use sip-" +
			                  QString(EXECUTABLE_NAME).toLower()
			           << "with" << QString(EXECUTABLE_NAME).toLower() + "-fetch-config as an argument.";
			QHash<QString, QString> args = parseArgs(command);
			QString fetchUrl;
			if (args.contains("fetch-config") || args.contains(QString(EXECUTABLE_NAME).toLower() + "fetch-config")) {
				if (args.contains("fetch-config"))
					lWarning() << "\"fetch-config\" argument is deprecated and will be removed in further version. "
					              "Please use \"" +
					                  QString(EXECUTABLE_NAME).toLower() + "fetch-config\" instead";
				fetchUrl = decodeBase64Url(args["fetch-config"]);
			} else {
				QUrl url(command.mid(deprecatedConfigURI.size() + 1)); // Remove 'exec-config:'
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
			QString qAddress = transformedCommand; //.left(transformedCommand.indexOf('?'));
			if (Utils::isUsername(transformedCommand)) {
				address = linphone::Factory::get()->createAddress(
				    Utils::appStringToCoreString(transformedCommand + "@to.remove"));
				address->setDomain("");
				qAddress = Utils::coreStringToAppString(address->asString());
				if (address && qAddress.isEmpty()) qAddress = transformedCommand;
			} else {
				address = linphone::Factory::get()->createAddress(
				    Utils::appStringToCoreString(qAddress)); // Test if command is an address
			}
			// if (format) *format = UriFormat;

			lInfo() << log().arg("Detecting URI command: `%1`…").arg(command);
			QString functionName;
			if (address) {
				bool useCallHeader = false;
				if (!Utils::coreStringToAppString(address->getHeader("method")).isEmpty()) {
					if (scheme == "sip" || scheme == "sips") {
						useCallHeader = true;
					} else {
						lWarning() << "\"method\" argument is deprecated. Use \"" + QString(EXECUTABLE_NAME).toLower() +
						                  "-action\" instead.";
						//: Deprecated
						// Utils::showInformationPopup(
						//     tr("cli_command_deprecated_title"),
						//     //: "\"method\" argument is deprecated and will be removed in further version. Use" <<
						//     //: QString(EXECUTABLE_NAME).toLower() + "\"-action\" instead."
						//     tr("cli_command_deprecated_message"), false);
						functionName = Utils::coreStringToAppString(address->getHeader("method"));
					}

				} else if (!Utils::coreStringToAppString(
				                address->getHeader(QString(EXECUTABLE_NAME).toLower().toStdString() + "-action"))
				                .isEmpty()) {
					if (scheme == "sip" || scheme == "sips") {
						useCallHeader = true;
					} else {
						functionName = Utils::coreStringToAppString(
						    address->getHeader(QString(EXECUTABLE_NAME).toLower().toStdString() + "-action"));
					}
				} else if (!Utils::coreStringToAppString(
				                address->getHeader(QString(EXECUTABLE_NAME).toLower().toStdString() + "-fetch-config"))
				                .isEmpty()) {
					if (scheme == "sip" || scheme == "sips") {
						useCallHeader = true;
					} else {
						functionName = "fetch-config";
					}
				} else if (!Utils::coreStringToAppString(
				                address->getHeader(QString(EXECUTABLE_NAME).toLower().toStdString() + "-use-sips"))
				                .isEmpty()) {
					if (scheme == "sip" || scheme == "sips") {
						useCallHeader = true;
					} else {
						functionName = "use-sips";
					}
				} else functionName = QStringLiteral("call");
				if (useCallHeader) {
					lWarning() << log().arg(
					    "sip and sips scheme does not take arguments into account anymore. Use sip-" +
					    QString(EXECUTABLE_NAME).toLower() + " instead.");
					functionName = QStringLiteral("call");
				}

			} else {
				QStringList fields = command.split('?');
				if (fields.size() > 1) {
					if (scheme == "sip" || scheme == "sips") {
						lWarning() << log().arg(
						    "sip and sips scheme does not take arguments into account anymore. Use sip-" +
						    QString(EXECUTABLE_NAME).toLower() + " instead.");
					} else {
						fields = fields[1].split('&');
						for (int i = 0; i < fields.size() && functionName.isEmpty(); ++i) {
							QStringList data = fields[i].split('=');
							if (data[0] == "method" && data.size() > 1) {
								lWarning() << "\"method\" argument is deprecated. Use \"" +
								                  QString(EXECUTABLE_NAME).toLower() + "-action\" instead.";
								//: Deprecated
								// Utils::showInformationPopup(
								//     tr("cli_command_deprecated_title"),
								//     //: "\"method\" argument is deprecated and will be removed in further
								//     version. Use"
								//     <<
								//     //: QString(EXECUTABLE_NAME).toLower() + "\"-action\" instead."
								//     tr("cli_command_deprecated_message"), false);
								functionName = data[1];
							} else if (data[0].startsWith(QString(EXECUTABLE_NAME).toLower() + "-") &&
							           data.size() > 1) {
								functionName = data[0];
								functionName.remove(QString(EXECUTABLE_NAME).toLower() + "-");
								lInfo() << "Detecting parameter method" << functionName;
								if (functionName == "action") {
									functionName = data[1];
									lInfo() << "Using method" << functionName;
								}
							}
						}
					}
					if (functionName.isEmpty()) functionName = "call";
				}
			}

			functionName = functionName.toLower();
			if (functionName.isEmpty()) {
				lWarning() << log().arg("There is no method set in `%1`.").arg(command);
				return;
			} else if (!mCommands.contains(functionName)) {
				lWarning() << log().arg("This command doesn't exist: `%1`.").arg(functionName);
				return;
			}
			QHash<QString, QString> headers;
			if (address) {
				// TODO: check if there is too much headers.
				lInfo() << "scheme is" << scheme;
				for (const auto &argName : mCommands[functionName].mArgsScheme.keys()) {
					if (scheme == "sip" && scheme == "sips") {
						lWarning() << log().arg("This scheme does not support arguments");
						break;
					} else {
						const std::string header = address->getHeader(Utils::appStringToCoreString(argName));
						headers[argName] = decodeBase64Url(QByteArray(header.c_str(), int(header.length())));
					}
				}
				mCommands[functionName].executeUri(qAddress, headers, this);
			} else {
				mCommands[functionName].executeUrl(command, this);
			}
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