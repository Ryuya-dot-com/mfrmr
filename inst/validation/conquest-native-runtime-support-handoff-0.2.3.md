# ConQuest native-runtime support handoff for mfrmr 0.2.3

Status: withdrawn without sending, 2026-08-11.

This draft was prepared after restricted Codex launches of ConQuest 5.47.5
crashed while writing registry/settings XML. It must not be sent to ACER as a
product-failure report: the user demonstrated successful Terminal execution,
and the same SHA-matched executable subsequently completed a minimal `quit;`
command and all four sealed RSM/PCM q31/q61 arms outside the filesystem
sandbox.

The crash stack remains useful only as a local sandbox-compatibility finding:

```text
RegistryCheck
CRegistry::WriteInt
XMLFile::Put
XMLDataSet::Show
XMLElement::Show
MString::fwrite
fwrite
```

No external support request is currently warranted. If a future failure also
reproduces in ordinary Terminal execution, prepare a new report from that
unsandboxed reproduction rather than reviving this superseded draft. Do not
attach licence keys or assessment data.
