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

#include "PdfWidget.hpp"
#include "ui_PdfWidget.h"

#include <QDebug>
#include <QFileDialog>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPdfDocument>
#include <QPdfPageNavigation>
#include <QtMath>

#include "components/content/ContentModel.hpp"
#include "components/core/CoreManager.hpp"
#include "components/settings/SettingsModel.hpp"
#include "utils/Constants.hpp"
#include "utils/Utils.hpp"

const qreal zoomMultiplier = qSqrt(2.0);

PageSelector::PageSelector(QWidget *parent)
	: QWidget(parent)
	, mPageNavigation(nullptr){
	QHBoxLayout *layout = new QHBoxLayout(this);
	
	mPageNumberEdit = new QLineEdit(this);
	mPageNumberEdit->setAlignment(Qt::AlignRight);
	mPageNumberEdit->setStyleSheet("QLineEdit { border-radius: 5px; }");
	mPageCountLabel = new QLabel(this);
	mPageCountLabel->setText("0");
	layout->addWidget(mPageNumberEdit);
	layout->addWidget(mPageCountLabel);
}

void PageSelector::setPageNavigation(QPdfPageNavigation *pageNavigation){
	mPageNavigation = pageNavigation;
	
	connect(mPageNavigation, &QPdfPageNavigation::currentPageChanged, this, &PageSelector::onCurrentPageChanged);
	connect(mPageNavigation, &QPdfPageNavigation::pageCountChanged, this, [this](int pageCount){
		if(mPageNavigation->currentPage() == 0)
			mPageNumberEdit->setText("1");
		mPageCountLabel->setText(QString::fromLatin1("/ %1").arg(pageCount));
	});
	connect(mPageNumberEdit, &QLineEdit::editingFinished, this, &PageSelector::pageNumberEdited);
	
	onCurrentPageChanged(mPageNavigation->currentPage());
}

void PageSelector::onCurrentPageChanged(int page) {
	if (mPageNavigation->pageCount() == 0)
		mPageNumberEdit->setText(QString::number(0));
	else
		mPageNumberEdit->setText(QString::number(page + 1));
}

void PageSelector::pageNumberEdited() {
	if (!mPageNavigation)
		return;
	
	bool ok = false;
	const int pageNumber = mPageNumberEdit->text().toInt(&ok);
	
	if (!ok)
		onCurrentPageChanged(mPageNavigation->currentPage());
	else
		mPageNavigation->setCurrentPage(qBound(0, pageNumber - 1, mPageNavigation->pageCount() - 1));
}

void PageSelector::setFamilyFont(const QString& family){
	Utils::setFamilyFont(this, family);
	Utils::setFamilyFont(mPageNumberEdit, family);
	Utils::setFamilyFont(mPageCountLabel, family);
}
//------------------------------------------------------------------------------------------------------------------


PdfWidget::PdfWidget(ContentModel * contentModel, QWidget *parent)
	: QMainWindow(parent)
	, mContentModel(contentModel)
	, mUi(new Ui::PdfWidget)
	, mPageSelector(new PageSelector(this))
	, mDocument(new QPdfDocument(this)) {
	QSize size;
	mUi->setupUi(this);
	
// Icons
	mUi->downloadToolButton->setIcon(Utils::getMaskedPixmap("download_custom", "#CBCBCB"));
	mUi->fullscreenToolButton->setIcon(Utils::getMaskedPixmap("fullscreen_custom", "#CBCBCB"));
	mUi->rotationToolButton->setIcon(Utils::getMaskedPixmap("rotation_custom", "#CBCBCB"));
	mUi->zoomInToolButton->setIcon(Utils::getMaskedPixmap("zoom_in_custom", "#CBCBCB"));
	mUi->zoomOutToolButton->setIcon(Utils::getMaskedPixmap("zoom_out_custom", "#CBCBCB"));
	
	mUi->rotationToolButton->setVisible(false);// Rotation is not available.
	
// Fonts
	QString family;
	if(CoreManager::getInstance() && CoreManager::getInstance()->getSettingsModel())
		family = CoreManager::getInstance()->getSettingsModel()->getTextMessageFont().family();
	else
		family = Constants::DefaultFont;
	Utils::setFamilyFont(mUi->menuBar, family);
	Utils::setFamilyFont(mUi->menuView, family);
	Utils::setFamilyFont(mUi->menuZoom, family);
	Utils::setFamilyFont(mUi->actionZoom_In, family);
	Utils::setFamilyFont(mUi->actionZoom_Out, family);
	Utils::setFamilyFont(mUi->actionZoomFit_Width, family);
	Utils::setFamilyFont(mUi->actionZoomFit_Page, family);
	Utils::setFamilyFont(mUi->actionZoom25, family);
	Utils::setFamilyFont(mUi->actionZoom50, family);
	Utils::setFamilyFont(mUi->actionZoom70, family);
	Utils::setFamilyFont(mUi->actionZoom85, family);
	Utils::setFamilyFont(mUi->actionZoom100, family);
	Utils::setFamilyFont(mUi->actionZoom125, family);
	Utils::setFamilyFont(mUi->actionZoom150, family);
	Utils::setFamilyFont(mUi->actionZoom175, family);
	Utils::setFamilyFont(mUi->actionZoom200, family);
	Utils::setFamilyFont(mUi->actionZoom300, family);
	Utils::setFamilyFont(mUi->actionZoom400, family);
	Utils::setFamilyFont(mUi->actionPrevious_Page, family);
	Utils::setFamilyFont(mUi->actionNext_Page, family);
	Utils::setFamilyFont(mUi->actionContinuous, family);

	mPageSelector->setFamilyFont(family);
	
	mPageSelector->setMaximumWidth(150);
	mUi->statusBar->addPermanentWidget(mPageSelector);
	mPageSelector->setPageNavigation(mUi->pdfView->pageNavigation());
	
	//-------
	//		SEARCH
	//	QWidget * searchBox = new QWidget(this);
	//	QHBoxLayout * hbox = new QHBoxLayout(searchBox);
	//	QLineEdit *search = new QLineEdit(this);
	//	search->setPlaceholderText("Search...");
	//	search->setFrame(false);
	//	connect(search, &QLineEdit::textChanged, [](const QString &text){
	//
	//	});
	//	hbox->addWidget(search);
	//	QLabel * searchIcon = new QLabel(this);
	//
	//	searchIcon->setScaledContents(true);
	//	searchIcon->setPixmap(QPixmap("://assets/images/search_custom.svg"));
	//	hbox->addWidget(searchIcon);
	//	hbox->setSpacing(0);
	//	hbox->setContentsMargins(0,0,0,0);
	//	searchBox->setStyleSheet("QWidget { background-color : white}");
	//	searchBox->setContentsMargins(0,0,0,0);
	//
	//	mUi->mainToolBar->addWidget(searchBox);
	
	//		SEARCH
	//	searchBox->setMaximumHeight(fullscreen->height());
	//	searchIcon->setMaximumHeight(search->height());
	//	searchIcon->setMaximumWidth(searchIcon->height());
	
	mUi->pdfView->setDocument(mDocument);
	mUi->pdfView->setZoomMode(QPdfView::FitInView);
}

PdfWidget::PdfWidget(QWidget *parent) : PdfWidget(nullptr, parent){
}

PdfWidget::~PdfWidget(){
	delete mUi;
}

void PdfWidget::open(const QString &filePath) {
	mDocument->load(filePath);
	const auto documentTitle = mDocument->metaData(QPdfDocument::Title).toString();
	setWindowTitle(!documentTitle.isEmpty() ? documentTitle : tr("PDF Viewer"));
}

// Tools

void PdfWidget::on_fullscreenToolButton_toggled(bool checked){
	if(checked)
		this->showFullScreen();
	else
		this->showNormal();
}

void PdfWidget::on_downloadToolButton_clicked(){
	if(mContentModel){
		auto fileName = QFileDialog::getSaveFileName(this, tr("Export as..."));
		if(!fileName.isEmpty()){
			mContentModel->saveAs(fileName);
		}
	}
}

// Page

void PdfWidget::on_actionPrevious_Page_triggered(){
	mUi->pdfView->pageNavigation()->goToPreviousPage();
}

void PdfWidget::on_actionNext_Page_triggered(){
	mUi->pdfView->pageNavigation()->goToNextPage();
}

void PdfWidget::on_actionContinuous_triggered(){
	mUi->pdfView->setPageMode(mUi->actionContinuous->isChecked() ? QPdfView::MultiPage : QPdfView::SinglePage);
}

// Zoom

void PdfWidget::on_actionZoom_In_triggered(){
	mUi->pdfView->setZoomMode(QPdfView::CustomZoom);
	mUi->pdfView->setZoomFactor(mUi->pdfView->zoomFactor() * zoomMultiplier);
}

void PdfWidget::on_actionZoom_Out_triggered(){
	mUi->pdfView->setZoomMode(QPdfView::CustomZoom);
	mUi->pdfView->setZoomFactor(mUi->pdfView->zoomFactor() / zoomMultiplier);
}

void PdfWidget::setZoom(const double& percent){
	mUi->actionZoomFit_Width->setChecked(false);
	mUi->actionZoomFit_Page->setChecked(false);
	mUi->pdfView->setZoomMode(QPdfView::CustomZoom);
	mUi->pdfView->setZoomFactor(percent/100.0);
}

void PdfWidget::on_actionZoomFit_Width_triggered(){
	mUi->actionZoomFit_Page->setChecked(false);
	mUi->pdfView->setZoomMode(QPdfView::FitToWidth);
}

void PdfWidget::on_actionZoomFit_Page_triggered(){
	mUi->actionZoomFit_Width->setChecked(false);
	mUi->pdfView->setZoomMode(QPdfView::FitInView);
}

void PdfWidget::on_actionZoom25_triggered(){
	setZoom(25);
}

void PdfWidget::on_actionZoom50_triggered(){
	setZoom(50);
}

void PdfWidget::on_actionZoom70_triggered(){
	setZoom(70);
}

void PdfWidget::on_actionZoom85_triggered(){
	setZoom(85);
}

void PdfWidget::on_actionZoom100_triggered(){
	setZoom(100);
}

void PdfWidget::on_actionZoom125_triggered(){
	setZoom(125);
}

void PdfWidget::on_actionZoom150_triggered(){
	setZoom(150);
}

void PdfWidget::on_actionZoom175_triggered(){
	setZoom(175);
}

void PdfWidget::on_actionZoom200_triggered(){
	setZoom(200);
}

void PdfWidget::on_actionZoom300_triggered(){
	setZoom(300);
}

void PdfWidget::on_actionZoom400_triggered(){
	setZoom(400);
}
