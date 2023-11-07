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


#include "SpellChecker.hpp"
#include <libispell.h>
#include "app/paths/Paths.hpp"
#include <unistd.h>
#include <cstdio>
#include <string>
#include <linphone++/linphone.hh>
#include "utils/Utils.hpp"
#include <QCryptographicHash>

int SpellChecker::gISpell_sc_read_fd = 0;
int SpellChecker::gISpell_sc_write_fd = 0;
int SpellChecker::gISpell_app_read_fd = 0;
int SpellChecker::gISpell_app_write_fd = 0;
std::thread *SpellChecker::gISpellCheckerThread = nullptr;
QHash<QString,QStringList> SpellChecker::gISpellSuggestions;
std::string SpellChecker::gISpellCheckeCurrentLanguage;
std::shared_ptr<linphone::Config> SpellChecker::gISpellSelfDictionary = linphone::Factory::get()->createConfig(Paths::getISpellOwnDictsDirPath());
std::string SpellChecker::gIspellDictionariesFolder;


bool open_channel(int& read_fd, int& write_fd) {
	int vals[2];
	int errc = pipe(vals);
	if(errc) {
		return false;
	} else {
		read_fd = vals[0];
		write_fd = vals[1];
		return true;
	}
}

void SpellChecker::stopISpellChecker() {
	QString stop("__spellchecker_stop__");
	auto message = stop.toStdString();
	ssize_t amnt_written = write(gISpell_sc_write_fd, message.data(), message.size());
	if(amnt_written != message.size()) {
		qWarning() << LOG_TAG << "Linux ispell unable to stop spell checker";
	}
	gISpellCheckerThread->join();
	gISpellCheckerThread = nullptr;
	mAvailable = false;
}

void SpellChecker::setLanguage() {
	
	QString locale = SpellChecker::currentLanguage().toLower().mid(0,2);
	
	if (gISpellCheckeCurrentLanguage == locale.toStdString() && gISpellCheckerThread != nullptr) {
		mAvailable = true;
		return;
	}
	
	if (gISpellCheckerThread != nullptr) // Language change
		stopISpellChecker();
	
	QString dict = Paths::getISpellDictsDirPath()+locale+".hash";
	gIspellDictionariesFolder = Paths::getISpellDictsDirPath().toStdString();
	
	if (!QFile::exists(dict)) {
		qWarning() << LOG_TAG << "Linux ispell language not supported " << SpellChecker::currentLanguage() << dict;
		mAvailable = false;
		return;
	}
	
	if (!open_channel(gISpell_sc_read_fd, gISpell_sc_write_fd) ||
		!open_channel(gISpell_app_read_fd, gISpell_app_write_fd)) {
		qWarning() << LOG_TAG << "Linux ispell language unable to open channels";
		mAvailable = false;
		return;
	}
	
	gISpellCheckeCurrentLanguage = locale.toStdString();
	gISpellCheckerThread = new std::thread(bc_spell_checker,
										   gIspellDictionariesFolder.data(),
										   gISpellCheckeCurrentLanguage.data(),
										   gISpell_sc_read_fd,
										   gISpell_app_write_fd);
	
	mAvailable = true;
	qDebug() << LOG_TAG << "Linux ispell language loaded from " << dict;
}

// Few special situation in French language not detected by the fr.hash.

bool SpellChecker::wordValidWithFrVariants(QString word) {
	if (word.toLower().contains("qu'")) {
		QString replace = word.toLower().replace("qu'","que ");
		if (isValid(replace)||validSplittedOn(" ",replace))
			return true;
	}
	if (word.toLower().contains("s'")) {
		QString replace = word.toLower().replace("s'","se ");
		if (isValid(replace)||validSplittedOn(" ",replace))
			return true;
	}
	return false;
}

bool SpellChecker::validSplittedOn(QString pattern, QString word) {
	if (!word.contains(pattern))
		return false;
	auto split = word.split(pattern);
	return isValid(split[0]) && isValid(split[1]);
}

bool SpellChecker::isValid(QString word) {
	
	if (!mAvailable || word.length() == 1 || isLearnt(word))
		return true;
	
	// no letters in word -> valid
	QString wordCopy = word;
	auto iterator = std::remove_if(wordCopy.begin(), wordCopy.end(), [](const QChar& c){ return !c.isLetter();});
	wordCopy.chop(std::distance(iterator, wordCopy.end()));
	if (wordCopy.isEmpty())
		return true;
	
	// Some preformating
	
	word = word.replace("’","'");
	word = word.replace("(","");
	word = word.replace(")","");
	word = word.replace("‘","'");
	
	while (word.endsWith(".") || word.endsWith("!") || word.endsWith(",") || word.endsWith(","))
		word.chop(1);
	
	while (word.startsWith(".") || word.startsWith("!") || word.startsWith(",") || word.startsWith(",")) {
		word = word.mid(1);
	}
		
	// submit word to ispell
	auto message = word.toStdString();
	ssize_t amnt_written = write(gISpell_sc_write_fd, message.data(), message.size());
	if(amnt_written != message.size()) {
		qWarning() << LOG_TAG << "Linux ispell unable to communicate with spell checker thread";
		return true;
	}
	
	// wait and read ispell result
	constexpr int buffer_size = 1024;
	char buffer[buffer_size] = {0};
	ssize_t amnt_read = read(gISpell_app_read_fd, &buffer[0], buffer_size);
	QString returned = QString::fromUtf8(buffer);
	if (returned == "1") {
		return true;
	} else {
		if (!gISpellSuggestions.contains(word)) { // Record returned suggestions if any
			QStringList returnedUggestions = returned.split(", ");
			returnedUggestions.removeFirst();
			gISpellSuggestions.insert(word,returnedUggestions);
		}
		return	(gISpellCheckeCurrentLanguage == "fr" && wordValidWithFrVariants(word)) ||
			validSplittedOn("'",word) ||
			validSplittedOn("-",word);
	}

}

void SpellChecker::learn(QString word){
	QCryptographicHash hash( QCryptographicHash::Sha1 ); // Hash to avoid fancy character conflict with config format.
	hash.addData(word.toUtf8());
	auto hashString = Utils::appStringToCoreString(hash.result().toHex());
	gISpellSelfDictionary->setInt("words",hashString,1);
	gISpellSelfDictionary->sync();
	highlightDocument();
}

bool SpellChecker::isLearnt(QString word){
	QCryptographicHash hash( QCryptographicHash::Sha1 ); // Hash to avoid fancy character conflict with config format.
	hash.addData(word.toUtf8());
	auto hashString = Utils::appStringToCoreString(hash.result().toHex());
	return gISpellSelfDictionary->getInt("words",hashString,0) == 1;
}

QStringList SpellChecker::suggestionsForWord(QString word) {
	QStringList suggestions;
	if (!gISpellSuggestions.contains(word))
		return suggestions;
	QListIterator<QString> itr (gISpellSuggestions.value(word));
	while (itr.hasNext()) {
		QString suggestion = itr.next();
		if (!suggestion.contains("+"))
			suggestions <<  suggestion;
		if (suggestions.length() >= SUGGESTIONS_LIMIT) {
			return suggestions;
		}
	}
	return suggestions;
}
