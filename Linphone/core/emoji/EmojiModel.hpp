/*
 * MIT License

Copyright (c) 2023 AmirHosseinCH

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#ifndef EMOJIMODEL_H
#define EMOJIMODEL_H

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QObject>

class EmojiModel : public QObject {
	Q_OBJECT
	Q_PROPERTY(QString iconsPath WRITE setIconsPath MEMBER mIconsPath)
	Q_PROPERTY(QString iconsType WRITE setIconsType MEMBER mIconsType)
public:
	EmojiModel();
	void setIconsPath(QString);
	void setIconsType(QString);
public slots:
	int count(QString);
	QString path(QString, int, int = -1);
	QVector<QString> search(QString, int = -1);

private:
	QString mIconsPath;
	QString mIconsType;
	QMap<QString, QJsonArray> emojies;
	QMap<QString, QVector<QJsonObject>> keywords;
};

#endif
