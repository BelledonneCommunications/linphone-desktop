#ifndef UTILS_H_
#define UTILS_H_

#include <QString>

// ===================================================================

namespace Utils {
  inline QString linphoneStringToQString (const std::string &string) {
    return QString::fromLocal8Bit(string.c_str(), static_cast<int>(string.size()));
  }

  inline std::string qStringToLinphoneString (const QString &string) {
    return string.toStdString();
  }
}

#endif // UTILS_H_
