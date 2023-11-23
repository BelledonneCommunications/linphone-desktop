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
#include <QRegularExpression>
#include <QTimer>
#include <QAbstractTextDocumentLayout>
#include <QTextEdit>


#ifdef WIN32
#include <spellcheck.h>
#endif

SpellChecker::SpellChecker(QObject *parent) : QSyntaxHighlighter(parent) {
	errorFormater.setUnderlineStyle(QTextCharFormat::SpellCheckUnderline);
	errorFormater.setFontUnderline(true);
	errorFormater.setUnderlineColor(Qt::red); // not supported before Qt6.2
	
	QFontMetrics fm = QFontMetrics(CoreManager::getInstance()->getSettingsModel()->getTextMessageFont());
#ifdef __linux__
	wave = QString("‾");
	QRect boundingRect = fm.boundingRect(wave);
	waveHeight = 10;
	waveTopPadding = 5;
#else
	wave = QString(u8"\uFE4B");
	QRect boundingRect = fm.boundingRect(wave);
	waveHeight = 5;
	waveTopPadding = 3;
#endif
	waveWidth = boundingRect.width();
	
	graceTimer = new QTimer(this);
	graceTimer->setSingleShot(true);
	connect(graceTimer, SIGNAL(timeout()), SLOT(highlightAfterGracePeriod()));
	connect(CoreManager::getInstance()->getSettingsModel(), &SettingsModel::spellCheckerOverrideLocaleChanged, this, &SpellChecker::setLanguage);
	
	mAvailable = false;
	if (CoreManager::getInstance()->getSettingsModel()->getSpellCheckerEnabled())
		setLanguage();
}

SpellChecker::~SpellChecker () {
	graceTimer->stop();
#ifdef _WIN32
	if (mNativeSpellChecker != nullptr)
		mNativeSpellChecker->Release();
#endif

}


void SpellChecker::setTextDocument(QQuickTextDocument *textDocument) {
	setDocument(textDocument->textDocument());
}

/////////////////////////////////////////////////////////////////////////////////////////
// Should be this option but TextEdit/TextArea does not support setUnderlineColor
// (although QTextEdit does) until QT 6.2 (1d44ddf576 of qtdeclarative submodule)
/////////////////////////////////////////////////////////////////////////////////////////


void SpellChecker::highlightBlock(const QString &text) {
	// setFormat(begin, length, errorFormater);
}

/////////////////////////////////////////////////////////////////////////////////////.
// QT5 Option using repeater/unicode inside QML with calculation of redline positions.
/////////////////////////////////////////////////////////////////////////////////////.


QString SpellChecker::underLine(qreal minLength) {
	return wave.repeated(1+minLength/waveWidth);
}

void SpellChecker::highlightDocument() {
	if(!CoreManager::getInstance()->getSettingsModel()->getSpellCheckerEnabled()) return;
	if (!fromTimer && QDateTime::currentMSecsSinceEpoch() <= mLastHightlight + GRACE_PERIOD_SECS*1000) {
		scheduleHighlight();
		return;
	}
	
	redLines.clear();
	if (document() == nullptr) {
		emit redLinesChanged();
		return;
	}
	
	mLastHightlight = QDateTime::currentMSecsSinceEpoch();
	QTextBlock::iterator blockIterator = document()->begin().begin();
	QStringList newWords;
	bool hadActiveWord = false;
	QRegularExpression expression(WORD_DELIMITERS_REGEXP);
	while (!blockIterator.atEnd()) {
		QTextFragment fragment = blockIterator.fragment();
		QFontMetrics metrics(fragment.charFormat().font());
		QString text = fragment.text();
		int position = 0;
		QRegularExpressionMatchIterator blockWordsIterator = expression.globalMatch(text);
		while (blockWordsIterator.hasNext()) {
			QRegularExpressionMatch match = blockWordsIterator.next();
			QString word = match.captured();
			bool wordActive = !fromTimer && isWordActive(words, word, position);
			int begin = match.capturedStart();
			int length = match.capturedLength();
			bool ignoreOnce = wasIgnoredOnce(word, match.capturedStart(),match.capturedEnd());
			if (!wordActive && !ignoredAllWords.contains(word) && !ignoreOnce && !isValid(word) && !fragment.glyphRuns(begin,length).empty()) {
				QRectF boundingRect = fragment.glyphRuns(begin,length).first().boundingRect();
				QPointF start = boundingRect.bottomLeft();
				qreal width = boundingRect.width();
				redLines.append(QString::number(start.x())+","+QString::number(start.y())+","+QString::number(width)+","+underLine(width)+","+QString::number(waveHeight)+","+QString::number(waveTopPadding));
			}
			if (wordActive) {
				hadActiveWord = wordActive;
			}
			newWords.append(word);
			position++;
		}
		blockIterator++;
	}
	words = newWords;
	if (hadActiveWord && !fromTimer) {
		scheduleHighlight();
	}
	emit redLinesChanged();
}

void SpellChecker::clearHighlighting() {
	redLines.clear();
	emit redLinesChanged();
}

void SpellChecker::scheduleHighlight() {
	graceTimer->start(GRACE_PERIOD_SECS*1000);
}

bool SpellChecker::isWordActive(QStringList words, QString word, int index) {
	if (index >= words.length())
		return true;
	return words.at(index) != word ;
}

void SpellChecker::highlightAfterGracePeriod() {
	fromTimer = true;
	highlightDocument();
	fromTimer = false;
}

int SpellChecker::wordPosition(int x, int y) {
	int position =  document()->documentLayout()->hitTest( QPointF( x, y ), Qt::ExactHit );
	return position;
}

bool SpellChecker::isWordAtPositionValid(int cursorPosition) {
	QTextCursor cursor(document());
	cursor.setPosition(cursorPosition);
	cursor.select(QTextCursor::WordUnderCursor);
	QString word = cursor.selectedText();
	return isValid(word);
}

void SpellChecker::ignoreAll(QString word) {
	if (!ignoredAllWords.contains(word)) {
		ignoredAllWords.append(word);
	}
	highlightDocument();
}

void SpellChecker::ignoreOnce(QString word, int cursorPosition) {
	QTextCursor cursor(document());
	cursor.setPosition(cursorPosition);
	QTextBlock block = cursor.block();
	ignoredOnce[cursorPosition] = word;
	highlightDocument();
}

bool SpellChecker::wasIgnoredOnce(QString word, int wordStartIndex, int wordEndIndex) {
	for (int i = wordStartIndex; i<=wordEndIndex; i++) {
		if (ignoredOnce[i] == word)
			return true;
	}
	return false;
}

void SpellChecker::replace(QString word, QString byWord, int cursorPosition) {
	QTextCursor cursor(document());
	cursor.setPosition(cursorPosition);
	cursor.clearSelection();
	cursor.movePosition(QTextCursor::StartOfWord, QTextCursor::MoveAnchor);
	cursor.movePosition(QTextCursor::EndOfWord, QTextCursor::KeepAnchor);
	cursor.insertText(byWord);
	highlightDocument();
}
