#ifndef DATE_MODEL_H
#define DATE_MODEL_H

#include <QObject>
#include <QDate>

class DateModel: public QObject, public QDate{
    Q_OBJECT
    Q_PROPERTY(int year READ getYear WRITE setYear NOTIFY yearChanged)
    Q_PROPERTY(int month READ getMonth WRITE setMonth NOTIFY monthChanged)
    Q_PROPERTY(int day READ getDay WRITE setDay NOTIFY dayChanged)

public:
    DateModel(QObject * parent = 0);
    DateModel(QDate date, QObject * parent = 0);
    ~DateModel();

	int getYear() const;
	void setYear(int year);
	
	int getMonth() const;
	void setMonth(int month);
	
	int getDay() const;
	void setDay(int day);
	
	Q_INVOKABLE int dayOfWeek() const;
	Q_INVOKABLE bool isEqual(DateModel * model);
	Q_INVOKABLE bool isGreatherThan(DateModel * model);
	Q_INVOKABLE QString toDateString(const QString& format = "yyyy/MM/dd") const;
signals:
    void yearChanged();
    void monthChanged();
    void dayChanged();

};
Q_DECLARE_METATYPE(DateModel*);

#endif
