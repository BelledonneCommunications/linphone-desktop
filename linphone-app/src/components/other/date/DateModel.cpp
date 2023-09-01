#include "DateModel.hpp"

#include <QDateTime>
#include <QDebug>

#include "utils/Utils.hpp"
DateModel::DateModel(QObject * parent) : QObject(parent){
}

DateModel::DateModel(QDate date, QObject * parent) : QObject(parent), QDate(date) {
}

DateModel::~DateModel(){
}

int DateModel::getYear() const{
	return QDate::year();
}

void DateModel::setYear(int year){
	QDate::setDate(year, month(), day());
	emit yearChanged();
}

int DateModel::getMonth() const{
	return month();
}
void DateModel::setMonth(int month){
	QDate::setDate(year(), month, day());
	emit monthChanged();
}

int DateModel::getDay() const{
	return day();
}

void DateModel::setDay(int day) {
	QDate::setDate(year(), month(), day);
	emit dayChanged();
}

int DateModel::dayOfWeek() const {
	return QDate::dayOfWeek();
}

bool DateModel::isEqual(DateModel * model)  {
	return *dynamic_cast<QDate*>(this) == *dynamic_cast< QDate*>(model);
}

bool DateModel::isGreatherThan(DateModel * model) {
	return *dynamic_cast<QDate*>(this) >= *dynamic_cast<QDate*>(model);
}

QString DateModel::toDateString(const QString& format) const {
	return Utils::toDateString(*this, format);
}