/*
 * Copyright (c) 2021 Belledonne Communications SARL.
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

#ifndef COLOR_LIST_MODEL_H_
#define COLOR_LIST_MODEL_H_

// =============================================================================
#include <QObject>
#include <QDateTime>
#include <QString>
#include <memory> 
#include <QQmlPropertyMap>
#include <QSharedPointer>

#include "ColorModel.hpp"
#include "app/proxyModel/ProxyListModel.hpp"

#define ADD_COLOR(COLOR, VALUE, DESCRIPTION) \
	color = QSharedPointer<ColorModel>::create(COLOR, VALUE, DESCRIPTION); \
	add(color);

#define ADD_COLOR_WITH_LINK(COLOR, VALUE, DESCRIPTION, LINK) \
	add(COLOR,LINK,DESCRIPTION,VALUE);
	
// Alpha is in percent.
#define ADD_COLOR_WITH_ALPHA(COLOR, ALPHA, DESCRIPTION) \
	color = QSharedPointer<ColorModel>::create(COLOR + QString::number(ALPHA), mData[COLOR].value<ColorModel*>()->getColor().name(), DESCRIPTION); \
	color->setAlpha(ALPHA * 255 / 100); \
	add(color);
	
	
class ColorModel;

class ColorListModel : public ProxyListModel {
	Q_OBJECT
	void init() {
		QSharedPointer<ColorModel> color;
		ADD_COLOR("a", "transparent", "Generic transparent color.")
		// Primary color for hovered items.
		ADD_COLOR("b", "#D64D00", "Primary color for hovered items.")
		
		ADD_COLOR("c", "#CBCBCB", "Button pressed, separatos, fields.")
		ADD_COLOR("d", "#5A585B", "Text (Ephemerals)")
		ADD_COLOR("e", "#F3F3F3", "Chat text area Background")
		ADD_COLOR("f", "#E8E8E8", "Border color")
		ADD_COLOR("g", "#6B7A86", "SIP Address; Text of Contact, question popup; Selected button.")
		ADD_COLOR("h", "#687680", "Others")
		
		// Primary color.
		ADD_COLOR("i", "#FE5E00", "Primary color.")
		
		ADD_COLOR("j", "#4B5964", "Username, Background cancel button hovered.")
		
		// Popups, home, call, assistant and settings background.
		ADD_COLOR("k", "#FFFFFF", "Popups, home, call, assistant and settings background.")
		
		ADD_COLOR("l", "#000000", "Generic Black color")
		
		// Primary color for clicked items.
		ADD_COLOR("m", "#FF8600", "Primary color for clicked items.")
		
		ADD_COLOR("n", "#A1A1A1", "Pressed button")
		ADD_COLOR("o", "#D0D8DE", "Disabled button")
		
		ADD_COLOR("p", "#17A81A", "Progress bar.")
		
		ADD_COLOR("q", "#FFFFFF", "Fields, backgrounds and text color on some items")
		
		ADD_COLOR("r", "#909fab", "Background button normal.")
		
		ADD_COLOR("s", "#96be64", "Security")
		ADD_COLOR("unsecure", "#FF0000", "Unsecure")
		
		
		ADD_COLOR("t", "#C2C2C2", "Title Header")
		ADD_COLOR("u", "#D2D2D2", "Menu border (message)")
		ADD_COLOR("v", "#E7E7E7", "Menu pressed (message)")
		ADD_COLOR("w", "#EDEDED", "Menu background (conversation)")
		
		ADD_COLOR("x", "#D0D8DE", "Background unselected round button")
		
		ADD_COLOR("y", "#FFFFFF", "Gradient dialog start")
		ADD_COLOR("z", "#E2E2E2", "Gradient dialog end")
		
		ADD_COLOR("aa", "#E1E1E1", "Chat text outside background")
		ADD_COLOR("ab", "#979797", "Chat heading section text")
		ADD_COLOR("ac", "#B1B1B1", "Chat bubble author/ text")
		ADD_COLOR("ad", "#FF5E00", "Ephemeral main color")
		ADD_COLOR("ae", "#FF0000", "Important message")
		ADD_COLOR("af", "#9FA6AB", "Admin Status")
		ADD_COLOR("ag", "#EBEBEB", "Line between items in list")
		ADD_COLOR("ah", "#F5F5F5", "Main List item background")
		ADD_COLOR("ai", "#FFFFFF", "Foreground color on buttons")
		ADD_COLOR("slider_bg", "#bdbebf", "Slider background")
		ADD_COLOR("slider_low", "#21be2b", "Slider low value")
		ADD_COLOR("slider_high", "#ff0000", "Slider high value")
		ADD_COLOR("event_neutral", "#424242", "Event colors that are neutral")
		ADD_COLOR("event_in", "#96C11F", "Event colors that are incoming")
		ADD_COLOR("event_out", "#18A7AF", "Event colors that are outgoing")
		
		ADD_COLOR("avatar_initials_bg", "#AFAFAF", "Avatar : Background for initials")
		ADD_COLOR("avatar_initials_sticker_bg", "transparent", "Avatar : Sticker background for avatar initials")
		
		ADD_COLOR("conference_entry_bg", "#D0D8DE", "Conferences : Background entry")
		
		
		ADD_COLOR("conference_bg", "#798791", "Conferences: Background")
		ADD_COLOR("conference_avatar_sticker_bg", "#A1A1A1", "Conferences : Background for sticker avatar")
		ADD_COLOR("conference_avatar_initials_bg", "#798791", "Conferences : Background for avatar initials")
		
		ADD_COLOR("fullscreen_conference_bg", "black", "Conferences: Fullscreen background")
		
		ADD_COLOR("validation", "#96C11F", "Background for validation on buttons")
		ADD_COLOR("validation_h", "#7B9D1B", "Hovered background for validation on buttons")
		
		ADD_COLOR("readonly_fg", "#B1B1B1", "Chat text area Readonly foreground")
		
		ADD_COLOR("telkeypad_bg", "#4D5B66", "Background for phone keypad")
		ADD_COLOR("telkeypad_fg", "#E4E4E4", "Foreground for phone keypad")
		ADD_COLOR("telkeypad_h", "#B1B1B1", "Foreground for phone keypad")
		
		ADD_COLOR("progress_bg", "black", "Background of round progress bar")
		ADD_COLOR("progress_remaining_fg", "white", "Remaining progression color")
		
		ADD_COLOR("timeline_bg_1", "#EFF0F2", "Timeline background color 1")
		ADD_COLOR("timeline_bg_2", "#FFFFFF", "Timeline background color 2")

// Keywords: 'mKeywordsMap'
//		s=standard, ma=main, l=list, sc=screen, me=menu
//		n=normal, d=disabled, h=hovered, p=pressed, u=updating, c=checked
//		b=button
//		inv=inverse
//		bg=background, fg=foreground

// Standard actions : 
		ADD_COLOR("s_n_b_bg", "#96A5B1", "[M] Standard normal button : background")
		ADD_COLOR("s_d_b_bg", "#D0D8DE", "[M] Standard disabled button : background")
		ADD_COLOR("s_h_b_bg", "#4B5964", "[M] Standard hovered button : background")
		ADD_COLOR("s_p_b_bg", "#FF5E00", "[M] Standard pressed button : background")
		
		ADD_COLOR("s_n_b_fg", "white", "[M] Standard normal button : foreground")
		ADD_COLOR("s_d_b_fg", "white", "[M] Standard disabled button : foreground")
		ADD_COLOR("s_h_b_fg", "white", "[M] Standard hovered button : foreground")
		ADD_COLOR("s_p_b_fg", "white", "[M] Standard pressed button : foreground")
		/*
// Inverse
		ADD_COLOR("s_n_b_inv_bg", "transparent", "Standard normal button : inverse background")
		ADD_COLOR("s_d_b_inv_bg", "transparent", "Standard disabled button : inverse background")
		ADD_COLOR("s_h_b_inv_bg", "transparent", "Standard hovered button : inverse background")
		ADD_COLOR("s_p_b_inv_bg", "transparent", "Standard pressed button : inverse background")
		
		ADD_COLOR("s_n_b_inv_fg", "black", "Standard normal button : inverse foreground")
		ADD_COLOR("s_d_b_inv_fg", "black", "Standard disabled button : inverse foreground")
		ADD_COLOR("s_h_b_inv_fg", "black", "Standard hovered button : inverse foreground")
		ADD_COLOR("s_p_b_inv_fg", "black", "Standard pressed button : inverse foreground")
		*/
//----------------------------
// Main Actions : like home button 
		ADD_COLOR("ma_n_b_bg", "#FF5E00", "[M] Main normal button : background")
		ADD_COLOR("ma_d_b_bg", "#FFCEB2", "[M] Main disabled button : background")
		ADD_COLOR("ma_h_b_bg", "#4B5964", "[M] Main hovered button : background")
		ADD_COLOR("ma_p_b_bg", "#DC4100", "[M] Main pressed button : background")
		
		ADD_COLOR("ma_n_b_fg", "white", "[M] Main normal button : foreground")
		ADD_COLOR("ma_d_b_fg", "white", "[M] Main disabled button : foreground")
		ADD_COLOR("ma_h_b_fg", "white", "[M] Main hovered button : foreground")
		ADD_COLOR("ma_p_b_fg", "white", "[M] Main pressed button : foreground")
//-------------------------------------
// Accept Actions : like accepting a call 
		ADD_COLOR("a_n_b_bg", "#9ECD1D", "[M] Accept normal button : background")
		ADD_COLOR("a_d_b_bg", "#809ECD1D", "[M] Accept disabled button : background")
		ADD_COLOR("a_h_b_bg", "#7D9F21", "[M] Accept hovered button : background")
		ADD_COLOR("a_p_b_bg", "#9ECD1D", "[M] Accept pressed button : background")
		
		ADD_COLOR("a_n_b_fg", "white", "[M] Accept normal button : foreground")
		ADD_COLOR("a_d_b_fg", "white", "[M] Accept disabled button : foreground")
		ADD_COLOR("a_h_b_fg", "white", "[M] Accept hovered button : foreground")
		ADD_COLOR("a_p_b_fg", "white", "[M] Accept pressed button : foreground")
//-------------------------------------
// Reject Actions : like rejecting a call
		ADD_COLOR("r_n_b_bg", "#FF5E00", "[M] Reject normal button : background")
		ADD_COLOR("r_d_b_bg", "#80FF5E00", "[M] Reject disabled button : background")
		ADD_COLOR("r_h_b_bg", "#DC4100", "[M] Reject hovered button : background")
		ADD_COLOR("r_p_b_bg", "#FF5E00", "[M] Reject pressed button : background")
		
		ADD_COLOR("r_n_b_fg", "white", "[M] Reject normal button : foreground")
		ADD_COLOR("r_d_b_fg", "white", "[M] Reject disabled button : foreground")
		ADD_COLOR("r_h_b_fg", "white", "[M] Reject hovered button : foreground")
		ADD_COLOR("r_p_b_fg", "white", "[M] Reject pressed button : foreground")
//-------------------------------------
// List Actions : like dot menu in chat
		ADD_COLOR("l_n_b_bg", "transparent", "[M] List normal button : background")
		ADD_COLOR("l_d_b_bg", "transparent", "[M] List disabled button : background")
		ADD_COLOR("l_h_b_bg", "transparent", "[M] List hovered button : background")
		ADD_COLOR("l_p_b_bg", "transparent", "[M] List pressed button : background")
		ADD_COLOR_WITH_LINK("l_u_b_bg", "", "[M] List updating button : background", "l_p_b_bg")
		
		ADD_COLOR("l_n_b_fg", "#4B5964", "[M] List normal button : foreground")
		ADD_COLOR("l_d_b_fg", "#8096A5B1", "[M] List disabled button : foreground")
		ADD_COLOR("l_h_b_fg", "#96A5B1", "[M] List hovered button : foreground")
		ADD_COLOR("l_p_b_fg", "#FF5E00", "[M] List pressed button : foreground")
		ADD_COLOR_WITH_LINK("l_u_b_fg", "", "[M] List updating button : foreground", "l_p_b_fg")

//-------------------------------------		
// Menu Actions
		ADD_COLOR("me_n_b_bg", "transparent", "[M] Menu normal button : background")
		ADD_COLOR("me_d_b_bg", "transparent", "[M] Menu disabled button : background")
		ADD_COLOR("me_h_b_bg", "transparent", "[M] Menu hovered button : background")
		ADD_COLOR("me_p_b_bg", "transparent", "[M] Menu pressed button : background")
		ADD_COLOR_WITH_LINK("me_u_b_bg", "", "[M] Menu updating button : background", "me_p_b_bg")
		
		ADD_COLOR("me_n_b_fg", "#4B5964", "[M] Menu normal button : foreground")
		ADD_COLOR("me_d_b_fg", "#8096A5B1", "[M] Menu disabled button : foreground")
		ADD_COLOR("me_h_b_fg", "#96A5B1", "[M] Menu hovered button : foreground")
		ADD_COLOR("me_p_b_fg", "#FF5E00", "[M] Menu pressed button : foreground")
		ADD_COLOR_WITH_LINK("me_u_b_fg", "", "[M] Menu updating button : background", "me_p_b_fg")
// Inverse
		ADD_COLOR("me_n_b_inv_bg", "transparent", "[M] Menu normal button : inverse background")
		ADD_COLOR("me_d_b_inv_bg", "transparent", "[M] Menu disabled button : inverse background")
		ADD_COLOR("me_h_b_inv_bg", "transparent", "[M] Menu hovered button : inverse background")
		ADD_COLOR("me_p_b_inv_bg", "transparent", "[M] Menu pressed button : inverse background")
		ADD_COLOR("me_c_b_inv_bg", "#FF5E00", "[M] Menu checked button : inverse background")
		
		ADD_COLOR("me_n_b_inv_fg", "white", "[M] Menu normal button : inverse foreground")
		ADD_COLOR("me_d_b_inv_fg", "#80FFFFFF", "[M] Menu disabled button : inverse foreground")
		ADD_COLOR("me_h_b_inv_fg", "#B0FFFFFF", "[M] Menu hovered button : inverse foreground")
		ADD_COLOR("me_p_b_inv_fg", "white", "[M] Menu pressed button : inverse foreground")
		ADD_COLOR("me_c_b_inv_fg", "white", "[M] Menu checked button : inverse foreground")
//-------------------------------------	
// Wave Play
		ADD_COLOR_WITH_LINK("w_n_b_bg", "", "[M] Wave play normal button : background", "ma_n_b_bg")
		ADD_COLOR_WITH_LINK("w_d_b_bg", "", "[M] Wave play disabled button : background", "ma_d_b_bg")
		ADD_COLOR_WITH_LINK("w_h_b_bg", "", "[M] Wave play hovered button : background", "ma_h_b_bg")
		ADD_COLOR_WITH_LINK("w_p_b_bg", "", "[M] Wave play pressed button : background", "ma_p_b_bg")
		
		ADD_COLOR_WITH_LINK("w_n_b_fg", "", "[M] Wave play normal button : foreground", "ma_n_b_fg")
		ADD_COLOR_WITH_LINK("w_d_b_fg", "", "[M] Wave play disabled button : foreground", "ma_d_b_fg")
		ADD_COLOR_WITH_LINK("w_h_b_fg", "", "[M] Wave play hovered button : foreground", "ma_h_b_fg")
		ADD_COLOR_WITH_LINK("w_p_b_fg", "", "[M] Wave play pressed button : foreground", "ma_p_b_fg")
		
// Wave Record
		ADD_COLOR("wr_n_b_bg", "transparent", "[M] Wave record normal button : background")
		ADD_COLOR("wr_d_b_bg", "transparent", "[M] Wave record disabled button : background")
		ADD_COLOR("wr_h_b_bg", "transparent", "[M] Wave record hovered button : background")
		ADD_COLOR("wr_p_b_bg", "transparent", "[M] Wave record pressed button : background")
		
		ADD_COLOR("wr_n_b_fg", "#96A5B1", "[M] Wave record normal button : foreground")
		ADD_COLOR("wr_d_b_fg", "#96A5B1", "[M] Wave record disabled button : foreground")
		ADD_COLOR("wr_h_b_fg", "#4B5964", "[M] Wave record hovered button : foreground")
		ADD_COLOR("wr_p_b_fg", "#FF5E00", "[M] Wave record pressed button : foreground")
				
//--------------------------------------------------------------------------------------------------------------------
/*		
		ADD_COLOR("m_b_bg_h", "#4B5964", "Main color for hovered buttons(background)")
		ADD_COLOR("m_b_bg_p", "#DC4100", "Main color for pressed buttons(background)")
		ADD_COLOR("m_b_fg_n", "#FFFFFF", "Main color for normal buttons(foreground)")
		ADD_COLOR_WITH_LINK("m_b_fg_h", "", "Main color for hovered buttons(foreground)", "m_b_fg_n")
		ADD_COLOR_WITH_LINK("m_b_fg_p", "", "Main color for pressed buttons(foreground)", "m_b_fg_n")
		
		
		
		ADD_COLOR_WITH_LINK("m_b_bg_n", "", "Main color for normal buttons(background)", "i")
		ADD_COLOR("m_b_bg_h", "#4B5964", "Main color for hovered buttons(background)")
		ADD_COLOR("m_b_bg_p", "#DC4100", "Main color for pressed buttons(background)")
		ADD_COLOR("m_b_fg_n", "#FFFFFF", "Main color for normal buttons(foreground)")
		ADD_COLOR_WITH_LINK("m_b_fg_h", "", "Main color for hovered buttons(foreground)", "m_b_fg_n")
		ADD_COLOR_WITH_LINK("m_b_fg_p", "", "Main color for pressed buttons(foreground)", "m_b_fg_n")
		
		ADD_COLOR("action_b_bg_n", "#96A6B1", "Action color for normal buttons(background)")
		ADD_COLOR("action_b_bg_h", "#4B5964", "Action color for hovered buttons(background)")
		ADD_COLOR("action_b_bg_p", "#FE5E00", "Action color for pressed buttons(background)")
		ADD_COLOR("action_b_fg_n", "white", "Action color for normal buttons(foreground)")
		ADD_COLOR_WITH_LINK("action_b_fg_h", "", "Action color for hovered buttons(foreground)", "action_b_fg_n")
		ADD_COLOR_WITH_LINK("action_b_fg_p", "", "Action color for pressed buttons(foreground)", "action_b_fg_n")
		
		ADD_COLOR("noBackground_b_n", "transparent", "Buttons with no background(normal)")
		ADD_COLOR_WITH_LINK("noBackground_b_h", "", "Buttons with no background(hovered)", "noBackground_b_n")
		ADD_COLOR_WITH_LINK("noBackground_b_p", "", "Buttons with no background(pressed)", "noBackground_b_n")
		ADD_COLOR("foreground_noBackground_b_n", "#96A6B1", "Normal buttons without background(foreground)")
		ADD_COLOR("foreground_noBackground_b_h", "#4B5964", "Hovered buttons without background(foreground)")
		ADD_COLOR("foreground_noBackground_b_p", "#DC4100", "Pressed buttons without background(foreground)")
		ADD_COLOR("foreground_noBackground_b_activated", "#FF5E00", "Activated buttons without background(foreground)")
		
		ADD_COLOR("inv_noBackground_b_n", "transparent", "Inverse color for normal buttons with no background(normal)")
		ADD_COLOR_WITH_LINK("inv_noBackground_b_h", "", "Inverse color for hovered buttons with no background(hovered)", "inv_noBackground_b_n")
		ADD_COLOR_WITH_LINK("inv_noBackground_b_p", "", "Inverse color for pressed buttons with no background(pressed)", "inv_noBackground_b_n")
		ADD_COLOR_WITH_LINK("inv_fg_noBackground_b_n", "", "Inverse color for normal buttons(foreground)", "foreground_noBackground_b_n")
		ADD_COLOR("inv_fg_noBackground_b_h", "white", "Inverse color for hovered buttons(foreground)")
		ADD_COLOR_WITH_LINK("inv_fg_noBackground_b_p", "", "Inverse color for pressed buttons(foreground)", "foreground_noBackground_b_p")
		ADD_COLOR_WITH_LINK("inv_fg_noBackground_b_activated", "", "Inverse color for activated buttons without background(foreground)", "foreground_noBackground_b_activated")
		
		ADD_COLOR("inv_fg_noBackground_b_h", "white", "Inverse color for hovered buttons(foreground)")
		
		
		ADD_COLOR("noBackground_b_n", "transparent", "Buttons with no background(normal)")
		ADD_COLOR_WITH_LINK("noBackground_b_h", "", "Buttons with no background(hovered)", "noBackground_b_n")
		ADD_COLOR_WITH_LINK("noBackground_b_p", "", "Buttons with no background(pressed)", "noBackground_b_n")
		ADD_COLOR("foreground_noBackground_b_n", "#96A6B1", "Inverse color for normal buttons(foreground)")
		ADD_COLOR("foreground_noBackground_b_h", "#4B5964", "Inverse color for hovered buttons(foreground)")
		ADD_COLOR("foreground_noBackground_b_p", "#DC4100", "Inverse color for pressed buttons(foreground)")
*/		
		
		ADD_COLOR("border", "black", "Borders")
		ADD_COLOR("border_light", "#A8A8A8", "Lighter borders")
		
		
		
		// Field error.
		ADD_COLOR("error", "#FF0000", "Error Generic button.")
		
		ADD_COLOR_WITH_ALPHA("g", 10, "")
		ADD_COLOR_WITH_ALPHA("g", 20, "")
		ADD_COLOR_WITH_ALPHA("g", 90, "")
		ADD_COLOR_WITH_ALPHA("i", 30, "")
		ADD_COLOR_WITH_ALPHA("j", 50, "")
		ADD_COLOR_WITH_ALPHA("j", 90, "")
		ADD_COLOR_WITH_ALPHA("l", 50, "")
		ADD_COLOR_WITH_ALPHA("l", 80, "")
		ADD_COLOR_WITH_ALPHA("q", 50, "")
		
		ADD_COLOR_WITH_LINK("event_bad", "", "Event colors that are bad", "error")
	}
public:
	
	ColorListModel (QObject *parent = nullptr);
	void initKeywords();
	
	virtual QHash<int, QByteArray> roleNames () const override;
	virtual QVariant data (const QModelIndex &index, int role = Qt::DisplayRole) const override;
	
	void useConfig (const std::shared_ptr<linphone::Config> &config);
	
	Q_INVOKABLE QString getNames();
	ColorModel * getColor(const QString& id);
	QVector<QStringList> getColorIdLinks();

// id: set an ID. If the ID already exist, the funtion return the item instead of create one.
// color : if empty, use the color from link
// description : describe the color
// idLink : link this color with another ID
	Q_INVOKABLE ColorModel * add(const QString& id, const QString& idLink, QString description = "", QString color = "");
	Q_INVOKABLE ColorModel * addImageColor(const QString& id, const QString& imageId, const QString& idLink, QString description = "", QString color = "");
	
	void addLink(const QString& a, const QString& b);
	void removeLink(const QString& a);
	Q_INVOKABLE void updateLink(const QString& id, const QString& newLink);
	
	QQmlPropertyMap * getQmlData();
	const QQmlPropertyMap * getQmlData() const;
	int getLinkIndex(const QString& id);
	
	
	void overrideColors (const std::shared_ptr<linphone::Config> &config);
	std::shared_ptr<linphone::Config> getConfigColors(const QString filename);
	
public slots:
	void handleUiColorChanged(const QString& id, const QColor& color);

signals:
	void colorChanged();
	
private:
	void add(QSharedPointer<ColorModel> imdn);
	QString buildDescription(QString description);	// return a description from id by splitting '_'
	
	QStringList getColorNames () const;
	
	QQmlPropertyMap mData;
	QVector<QStringList> mColorLinks;
	QMap<QString, int> mColorLinkIndexes;// Optimization for access
	QMap<QString, QVector<ColorModel*> > imageLinks;
	QMap<QString, QString> mKeywordsMap;	// Convert keyword into description
	
};
#undef ADD_COLOR
Q_DECLARE_METATYPE(QSharedPointer<ColorListModel>)

#endif 
