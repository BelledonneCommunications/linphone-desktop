/*
 * Copyright (c) 2010-2023 Belledonne Communications SARL.
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

// Open a Widnow to display a PDF.

#ifndef PDF_WIDGET_H_
#define PDF_WIDGET_H_

#include <QMainWindow>
#include <QWidget>

namespace Ui {
	class PdfWidget;
}

class ContentModel;
class PageSelector;
class QLabel;
class QLineEdit;
class QPdfDocument;
class QPdfPageNavigation;

class PdfWidget : public QMainWindow{
	Q_OBJECT
	
public:
	explicit PdfWidget(QWidget *parent = nullptr);
	explicit PdfWidget(ContentModel * contentModel, QWidget *parent = nullptr);
	~PdfWidget();
	
public slots:
	void open(const QString &filePath);
	void setZoom(const double& percent);
	
private slots:
	
	// Tools
	void on_downloadToolButton_clicked();
	void on_fullscreenToolButton_toggled(bool checked);
	
	// Page
	void on_actionPrevious_Page_triggered();
	void on_actionNext_Page_triggered();
	void on_actionContinuous_triggered();
	
	// Zoom
	void on_actionZoom_In_triggered();
	void on_actionZoom_Out_triggered();
	void on_actionZoomFit_Width_triggered();
	void on_actionZoomFit_Page_triggered();
	void on_actionZoom25_triggered();
	void on_actionZoom50_triggered();
	void on_actionZoom70_triggered();
	void on_actionZoom85_triggered();
	void on_actionZoom100_triggered();
	void on_actionZoom125_triggered();
	void on_actionZoom150_triggered();
	void on_actionZoom175_triggered();
	void on_actionZoom200_triggered();
	void on_actionZoom300_triggered();
	void on_actionZoom400_triggered();
	
private:
	Ui::PdfWidget *mUi;
	PageSelector *mPageSelector;
	
	QPdfDocument *mDocument;
	ContentModel * mContentModel;
};

class PageSelector : public QWidget {
	Q_OBJECT
public:
	explicit PageSelector(QWidget *parent = nullptr);
	
	void setPageNavigation(QPdfPageNavigation *pageNavigation);
	void setFamilyFont(const QString& family);
	
private slots:
	void onCurrentPageChanged(int page);
	void pageNumberEdited();
	
private:
	QLabel *mPageCountLabel;
	QPdfPageNavigation *mPageNavigation;
	QLineEdit *mPageNumberEdit;
};

#endif
