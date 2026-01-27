
if /i "%~2"=="Debug" (
    .\..\chromium-depot-tools\gn.bat gen %1 --args="extra_cflags=\"/MDd -Wno-nontrivial-memcall\""
) else (
    .\..\chromium-depot-tools\gn.bat gen %1 --args="extra_cflags=\"/MD -Wno-nontrivial-memcall\""
)