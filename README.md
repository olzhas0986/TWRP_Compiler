# AERA Recovery A16 compiler for munch

GitHub Actions build for POCO F4 / Redmi K40S, using the
[AERA Android 16 manifest](https://github.com/AERA-Recovery/android_manifest/tree/aera-16.0)
and [our munch device tree](https://github.com/olzhas0986/twrp_device_xiaomi_munch).

Open **Actions → AERA A16 - munch → Run workflow**. The DT ref defaults to
`android-12.1`, which currently contains the AERA adaptation; a commit SHA
can be supplied to reproduce a specific DT revision. That revision must
contain `aera_munch.mk`, `vendorsetup.sh` and `local_manifest.xml`.

The build imports the DT's extra Qualcomm dependencies before syncing,
sources its AERA settings, selects `twrp_munch-bp2a-eng`, and builds
`adbd bootimage`. Images are uploaded as `AERA-A16-munch-<run number>`;
logs and source revisions are uploaded separately even if the build fails.
Munch uses recovery-as-boot; the first test artifact is `boot.img`.

Sync and build job counts default to 4 and can be adjusted at dispatch.
The full Android sync runs on GitHub's runner and consumes substantial runner
disk space and traffic. Pushing this workflow does not start a build.

For a local build on Ubuntu 22.04 with dependencies and `repo` installed:

```bash
DT_REF=android-12.1 SYNC_JOBS=4 BUILD_JOBS=4 bash build.sh
```

`SOURCE_DIR` defaults to `./aera`. Use a fresh source directory per build.
The compiler does not establish boot or decryption compatibility: initial
device testing targets crDroid Android 17 QPR0 and requires recovery logs.
