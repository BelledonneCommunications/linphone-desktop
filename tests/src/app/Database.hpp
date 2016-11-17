#ifndef DATABASE_H_
#define DATABASE_H_

#include <string>

namespace Database {
  // Returns the databases paths.
  // If files cannot be created or are unavailable, a empty string is returned.
  // Use the directories separator of used OS.
  std::string getFriendsListPath ();
  std::string getCallHistoryPath ();
  std::string getMessageHistoryPath ();
};

#endif // DATABASE_H_
