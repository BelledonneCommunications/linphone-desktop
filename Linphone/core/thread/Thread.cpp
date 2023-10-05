#include "Thread.hpp"

Thread::Thread(QObject *parent) : QThread(parent) {
}

void Thread::run() {
	int toExit = false;
	while (!toExit) {
		int result = exec();
		if (result < 0) toExit = true;
	}
}