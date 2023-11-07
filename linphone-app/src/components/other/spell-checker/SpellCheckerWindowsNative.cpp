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

#include <spellcheck.h>
#include "SpellChecker.hpp"


void SpellChecker::setLanguage() {
	ISpellCheckerFactory* spellCheckerFactory;
	HRESULT hr = CoCreateInstance(__uuidof(SpellCheckerFactory), nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&spellCheckerFactory));
	if (!SUCCEEDED(hr)) {
		qWarning() << LOG_TAG << "Windows native spell checker unable to create spell checker factory";
		return;
	}
	QString locale = SpellChecker::currentLanguage().toUpper();
	LPCWSTR _locale = (const wchar_t*) locale.utf16();
	BOOL isSupported = FALSE;
	hr = spellCheckerFactory->IsSupported(_locale, &isSupported);
	if (!SUCCEEDED(hr)) {
		qWarning() << LOG_TAG << "Windows native spell checker unable to check if language is supported" << locale;
		return;
	}
	if (!isSupported) {
		qWarning() << LOG_TAG << "Windows native spell checker Language is not supported" << locale;
		locale = locale.mid(0,2);
		qWarning() << LOG_TAG << "Windows native spell checker trying with" << locale;
		_locale = (const wchar_t*) locale.utf16();
		hr = spellCheckerFactory->IsSupported(_locale, &isSupported);
		if (!SUCCEEDED(hr)) {
			qWarning() << LOG_TAG << "Windows native spell checker unable to check if language is supported" << locale;
			return;
		}
		if (!isSupported) {
			qWarning() << LOG_TAG << "Windows native spell checker Language is not supported" << locale;
			return;
		}
	}
	
	hr = spellCheckerFactory->CreateSpellChecker(_locale, &mNativeSpellChecker);
	if (!SUCCEEDED(hr)) {
		qWarning() << LOG_TAG << "Windows native spell checker unable to create spell checker";
		return;
	}
	qDebug() << LOG_TAG << "Windows native spell checker created for locale" << locale;
	mAvailable = true;
}


bool SpellChecker::isValid(QString word) {
	if (!mAvailable)
		return true;
	wchar_t *text = reinterpret_cast<wchar_t *>(word.data());
	IEnumSpellingError* enumSpellingError = nullptr;
	ISpellingError* spellingError = nullptr;
	HRESULT hr = mNativeSpellChecker->Check(text, &enumSpellingError);
	if (SUCCEEDED(hr)) {
		hr = enumSpellingError->Next(&spellingError);
		enumSpellingError->Release();
		return hr != S_OK;
	} else
		return true;
}

void SpellChecker::learn(QString word){
	if (mNativeSpellChecker == nullptr)
		return;
	wchar_t *text = reinterpret_cast<wchar_t *>(word.data());
	HRESULT hr = mNativeSpellChecker->Add(text);
	if (!SUCCEEDED(hr))
		qWarning() << LOG_TAG << "Windows native spell checke unable to add word to dictionary" << word;
	highlightDocument();
}

QStringList SpellChecker::suggestionsForWord(QString word) {
	QStringList suggestions;
	if (mNativeSpellChecker == nullptr)
		return suggestions;
	wchar_t *text = reinterpret_cast<wchar_t *>(word.data());
	IEnumString* enumString = nullptr;
	HRESULT hr = mNativeSpellChecker->Suggest(text, &enumString);
	if (SUCCEEDED(hr)) {
		while (S_OK == hr) {
			LPOLESTR string = nullptr;
			hr = enumString->Next(1, &string, nullptr);
			if (S_OK == hr) {
				suggestions << QString::fromWCharArray(string);
				CoTaskMemFree(string);
				if (suggestions.length() >= SUGGESTIONS_LIMIT) {
					enumString->Release();
					return suggestions;
				}
			}
		}
		enumString->Release();
	}
	return suggestions;
}
