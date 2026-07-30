#!/usr/bin/env python3
import os
import shutil
import sys

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SPECS_ROOT = os.path.join(REPO_ROOT, "external", "feature-specs")
SUITE_ROOT = os.path.join(REPO_ROOT, "tester", "squish", "suites", "cross-platform")

BDD_TEST_CASES = {
    "tst_BDD_Redial": "Features/call/redial.feature",
}


def main():
    for test_case, spec in sorted(BDD_TEST_CASES.items()):
        source = os.path.join(SPECS_ROOT, spec)
        if not os.path.exists(source):
            raise SystemExit(
                "missing spec %s\n"
                "The Gherkin specs live in the 'external/feature-specs' submodule; run:\n"
                "  git submodule update --init external/feature-specs" % source)
        target_dir = os.path.join(SUITE_ROOT, test_case)
        if not os.path.isdir(target_dir):
            raise SystemExit("unknown Squish test case: %s" % target_dir)
        target = os.path.join(target_dir, "test.feature")
        shutil.copyfile(source, target)
        sys.stdout.write("%s <- external/feature-specs/%s\n" % (os.path.relpath(target, REPO_ROOT), spec))


if __name__ == "__main__":
    main()
