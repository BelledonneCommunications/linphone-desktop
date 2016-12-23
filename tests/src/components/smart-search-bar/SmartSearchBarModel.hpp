#ifndef SMART_SEARCH_BAR_MODEL_H_
#define SMART_SEARCH_BAR_MODEL_H_

#include <QSortFilterProxyModel>

#include "../sip-addresses/SipAddressesModel.hpp"

// =============================================================================

class SmartSearchBarModel : public QSortFilterProxyModel {
  Q_OBJECT;

public:
  SmartSearchBarModel (QObject *parent = Q_NULLPTR);
  ~SmartSearchBarModel () = default;

  QHash<int, QByteArray> roleNames () const override;

public slots:
  void setFilter (const QString &pattern);

protected:
  bool filterAcceptsRow (int source_row, const QModelIndex &source_parent) const override;
  bool lessThan (const QModelIndex &left, const QModelIndex &right) const override;

private:
  int computeStringWeight (const QString &string) const;

  QString m_filter;
  static const QRegExp m_search_separators;
};

#endif // SMART_SEARCH_BAR_MODEL_H_
