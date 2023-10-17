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

#ifndef SPELLCHECKER_HPP_
#define SPELLCHECKER_HPP_

#include <stdio.h>
#include <QObject>
#include <QString>
#include <QDebug>
#include <QTextCharFormat>
#include <QSyntaxHighlighter>
#include <QTextDocument>
#include <QStringLiteral>
#include <QQuickTextDocument>
#include <QDateTime>
#include <QRegularExpression>
#include <QStringList>
#include <QTimer>
#include "app/App.hpp"

#define SUGGESTIONS_LIMIT 10
#define GRACE_PERIOD_SECS 1.0

#define LOG_TAG "[SpellChecker]"
#define WORD_DELIMITERS_REGEXP "[^\r\n\t\u2028 ]+"

#ifdef WIN32
class ISpellChecker;
#endif

class SpellChecker : public QSyntaxHighlighter {
	Q_OBJECT
public:
	SpellChecker(QObject* parent = nullptr);
	~SpellChecker();
	
	// Common
	static QString currentLanguage() { return App::getInstance()->getLocale().name();}
	Q_INVOKABLE void setTextDocument(QQuickTextDocument *textDocument);
	Q_INVOKABLE int wordPosition(int x, int y);
	Q_INVOKABLE bool isWordAtPositionValid(int cursorPosition);
	Q_INVOKABLE void highlightDocument();
	Q_INVOKABLE void clearHighlighting();
	Q_INVOKABLE void ignoreOnce(QString word, int cursorPosition);
	Q_INVOKABLE void ignoreAll(QString word);
	Q_INVOKABLE void replace(QString word, QString byWord, int cursorPosition);
	Q_PROPERTY(QStringList redLines MEMBER redLines NOTIFY redLinesChanged);
	
	// Native (Mac/Windows) or ISpell
	Q_INVOKABLE void learn(QString word);
	Q_INVOKABLE QStringList suggestionsForWord(QString word);
	bool isValid(QString word);
	
protected:
	void highlightBlock(const QString &text) override;
	
public slots:
	void highlightAfterGracePeriod();
	
signals:
	void redLinesChanged();
	
private:
	QTextCharFormat errorFormater;
	QTimer *graceTimer;
	bool fromTimer = false;
	QStringList ignoredAllWords;
	QList<QPair<QString, int>> ignoredOnceWords;
	QStringList redLines;
	QStringList words;
	QHash<int,QString> ignoredOnce;
	QString wave;
	qreal waveWidth;
	qint64 mLastHightlight;

	void setLanguage();
	bool isWordActive(QStringList words, QString word, int index);
	bool wasIgnoredOnce(QString word, int wordStartIndex, int wordEndIndex);
	void scheduleHighlight();
	QString underLine(qreal minLength);
#ifdef WIN32
	ISpellChecker* mNativeSpellChecker = nullptr;
#endif
};



#endif /* SPELLCHECKER_HPP_ */
