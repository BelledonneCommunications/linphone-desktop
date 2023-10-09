#include <QApplication>
#include <QQmlApplicationEngine>

#include <QLocale>
#include <QTranslator>

#include "core/App.hpp"

int main(int argc, char *argv[]) {
	App app(argc, argv);

	QTranslator translator;
	const QStringList uiLanguages = QLocale::system().uiLanguages();
	for (const QString &locale : uiLanguages) {
		const QString baseName = "Linphone_" + QLocale(locale).name();
		if (translator.load(":/i18n/" + baseName)) {
			app.installTranslator(&translator);
			break;
		}
	}

	int result = app.exec();
	return result;
}
