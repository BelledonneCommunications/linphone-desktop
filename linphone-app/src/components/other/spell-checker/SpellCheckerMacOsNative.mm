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


#import <AppKit/AppKit.h>
#import "SpellChecker.hpp"
  
void SpellChecker::setLanguage() {
	NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
	QString locale = SpellChecker::currentLanguage();
	if ([spellChecker setLanguage:locale.toNSString()]) {
		[spellChecker updatePanels];
		qDebug() << LOG_TAG << "Macos native spell checker Language set to " << locale;
		mAvailable = true;
	} else {
		qWarning() << LOG_TAG << "Macos native spell checker unable to set language to " << locale;
	}
}

bool SpellChecker::isValid(QString word) {
	if (!mAvailable)
		return true;
	NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
	QString locale = SpellChecker::currentLanguage();
	bool isValid = [spellChecker checkSpellingOfString:word.toNSString() startingAt:0 language:locale.toNSString() wrap:NO inSpellDocumentWithTag:0 wordCount:nullptr].length == 0;
	return isValid;
}

void SpellChecker::learn(QString word){
	NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
	NSString *_word = word.toNSString();
	if (![spellChecker hasLearnedWord:_word]) {
		[spellChecker learnWord:_word];
		[spellChecker updatePanels];
	}
	highlightDocument();
}

QStringList SpellChecker::suggestionsForWord(QString word) {
	NSSpellChecker *spellChecker = [NSSpellChecker sharedSpellChecker];
	NSString *_word = word.toNSString();
	QString locale = SpellChecker::currentLanguage();
	NSArray *_suggestions = [spellChecker guessesForWordRange:NSMakeRange(0, word.length()) inString:_word language:locale.toNSString() inSpellDocumentWithTag:0];
	QStringList suggestions;
	for (NSString *_suggestion in _suggestions) {
		QString suggestion = QString::fromNSString(_suggestion);
		suggestions << suggestion;
		if (suggestions.length() >= SUGGESTIONS_LIMIT)
			return suggestions;
	}
	return suggestions;
}
