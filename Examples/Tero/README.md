# TERO — Host Capture & Processing Framework

**TERO combines capture and initial processing into one workflow.**  
It collects volatile and non-volatile artifacts, optionally acquires memory, does basic integrity/packaging steps, and writes a tidy, timestamped case folder for offline forensics.

---

## What TERO Does

- Detects OS and architecture, chooses legacy or modern paths automatically.  
- Captures volatile state (processes, services, network, sessions).  
- Exports system and application event logs (EVT/EVTX).  
- Saves core registry hives (SYSTEM, SOFTWARE, SAM, SECURITY) and key DFIR artifacts (AppCompatCache, etc.).  
- Optionally captures memory if a supported RAM tool is present.  
- Runs initial processing: signature checks of hot paths, hashing/manifest, optional packaging.  
- Writes consistent, timestamped output per host for chain of custody.  

---

## Components (what’s in this branch)

- **Tero.bat** — main orchestrator (user menu, routing, capture + processing).  
- **Centaur.bat** — post-capture processing and helper flows (signature checks, packaging, etc.).  
- **legacy.bat** — Windows XP/2003–style collection with classic tools (no `wevtutil`, VBScript/EventLog fallbacks).  
- **Pegasus.ps1** — artifact collection module (registry, DFIR parsers like AppCompatCache).  
- **Pegasus Event Logs (rename to Pegasus).ps1** — EVT/EVTX export and fix-ups.  
- **kape.ps1** — wrapper for KAPE runs (targets/modules/bins if present).  
- **pegasuslogo.txt** — ASCII banner/branding.  
- **path.txt, mpath.txt, folder.txt, mfolder.txt** — path presets and example run markers for output layout.  

---

## Output Layout (typical)

Each run creates a folder like:  

`Collection\HOSTNAME--YYYY.MM.DD.HH.MM.--MODE\`

Inside you’ll commonly see:

- `*.log` — session and operator logs  
- `volatile\` — processes, services, sessions, network state  
- `registry\` — hive saves and parsed outputs  
- `eventlogs\` — `.evtx` (modern) or `.evt` (legacy) plus converted copies  
- `filesystem\` — startup items, prefetch, known artifact directories  
- `memory\` — memory image (e.g., `.zdmp`) if captured  
- `processed\` — sigcheck CSVs and other summaries  
- `archive\` — packaged results (ZIP/VHDX) when enabled  

---

## How to Run

**Default modern path (elevated CMD):**  
Run `Tero.bat` from the scripts directory and pass `--out`, `--case`, `--operator`.

**Legacy systems (XP/2003):**  
Run `legacy.bat` with your output location switches; this path avoids `wevtutil` and modern PowerShell features.

**Direct collectors:**  
- Event logs only: run the Pegasus Event Logs PowerShell script with an output root.  
- Full Pegasus collector: run Pegasus.ps1 with an output root.  
- KAPE integration: run kape.ps1 with output root and case/timestamp arguments expected by the script.  

*Keep filenames and directory structure as-is; many calls are hard-coded to sibling `binaries\`, `EZ\`, and `KAPE\` folders.*

---

## Chain of Custody & Integrity

- Session log is written per run in the host folder (timestamped).  
- Recommend MD5+SHA256 per file; on slow hosts, perform MD5 on-host and SHA256 later on the analysis workstation.  
- Maintain a `manifest.csv` (path, size, times, hashes) and optionally a `treehash.sha256` of the whole set.  

---

## Exact Binaries the TERO Scripts Reference

### Referenced in legacy.bat (architecture-aware paths)

- `rawcopy.exe` and `rawcopy64.exe` (locked file copying of system artifacts)  
- `extractusnjournal.exe` and `extractusnjournal64.exe` (USN Journal extraction)  
- `robocopy.exe` (copier; included on modern Windows, but mapped under `binaries\` for legacy)  
- `grep.exe` (GNU grep for Windows; text filtering)  
- `mmls.exe` (The Sleuth Kit — partition table mapping)  
- `mbrutil.exe` (MBR utilities; boot record info)  
- `sigcheck.exe` (Sysinternals — authenticity/signature/hashes)  
- `ftkimager_CLI.exe` (AccessData FTK Imager CLI; imaging/exports)  

Built-ins also used here: `eventquery.vbs`, `reg.exe`, `sc.exe`, `tasklist.exe`, `net.exe`, `netstat.exe`, `ipconfig.exe`, `arp.exe`, `route.exe`, `wmic.exe`, `schtasks.exe`, `vssadmin.exe`.  
`wevtutil.exe` is avoided in true legacy mode.  

### Referenced in kape.ps1

- `kape.exe` (KAPE runner under your `kape\` subtree)  
- `sigcheck.exe` and `sigcheck64.exe` (Sysinternals; conditional on OS bitness)  

Layout expected: `...\kape\kape.exe` plus `Modules\`, `Targets\`, `Bins\`.  

### Referenced in Pegasus.ps1

- `AppCompatCacheParser.exe` (under your `EZ\` folder; parses ShimCache/AppCompatCache to CSV)  

Relies on PowerShell built-ins for file system and registry operations.  

### Referenced in Pegasus Event Logs.ps1

- `evtkit.py` (under `binaries\`; fixes/copies legacy `.evt` sets before converting)  
- `wevtutil` (built-in on Vista+; exports `.evtx`)  

If calling `evtkit.py`, either package it as an EXE or include `python.exe` in `binaries\`.  

### Likely referenced elsewhere

- Memory acquisition: one of `winpmem.exe`, `dumpit.exe`, or `belkasoft_ramcapture.exe`  
- Archiving: `7z.exe` (if enabled)  
- Optional helpers: `streams.exe`, `RawCopy.exe`, `procdump.exe`, `WinDump.exe`, `md5deep.exe`, `sha256deep.exe`  

---

## Required Binaries Checklist (consolidated)

**Minimum set (beyond Windows built-ins):**  
- Sysinternals: `sigcheck.exe`, `sigcheck64.exe`  
- Imaging/export: `ftkimager_CLI.exe`  
- Copy/parse helpers: `rawcopy.exe`, `rawcopy64.exe`, `extractusnjournal.exe`, `extractusnjournal64.exe`, `robocopy.exe`, `grep.exe`, `mmls.exe`, `mbrutil.exe`  
- Parsers: `AppCompatCacheParser.exe` (place under `EZ\`)  
- Event log helper: `evtkit.py` (+ `python.exe` if not packaged)  
- Memory capture: `winpmem.exe` or `dumpit.exe` or `belkasoft_ramcapture.exe`  
- Packaging: `7z.exe`  

**Optional:**  
- `streams.exe`, `procdump.exe`, `WinDump.exe`, `md5deep.exe`, `sha256deep.exe`  
- KAPE: `kape.exe` with `Modules\`, `Targets\`, `Bins\`  

**Built-ins (do not ship):**  
`cmd.exe`, `reg.exe`, `sc.exe`, `tasklist.exe`, `net.exe`, `netstat.exe`, `ipconfig.exe`, `arp.exe`, `route.exe`, `wmic.exe`, `schtasks.exe`, `wevtutil.exe`, `vssadmin.exe`, `eventquery.vbs`, plus standard shell tools (`findstr`, `tree`, etc.).  
