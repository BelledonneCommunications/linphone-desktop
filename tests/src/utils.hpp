#include <QString>

namespace Utils {
  inline QString linphoneStringToQString (const std::string &string) {
    return QString::fromLocal8Bit(string.c_str(), string.size());
  }
}
