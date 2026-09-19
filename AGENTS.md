# Veldora OS workspace

This project builds an Archiso image. The user's everyday desktop is not the
deployment target. Keep development, generated profiles and previews inside this
repository. Never install or activate the project shell on the host, edit the
host's desktop settings, or send test input to its active session unless the user
explicitly requests those host changes. Use a staged ISO root or an isolated VM
for integration tests. Do not invoke the legacy desktop installer for ISO work.

Preserve existing uncommitted work. Use scripts/prepare-profile.sh and
scripts/build-iso.sh for ISO packaging, and validate staged assets and runtime
paths. Clearly distinguish profile validation from an actual ISO build or boot.
