# PERCIVAL — Host Capture Automation (Dev Scaffold)

> **What this is:** automation glue (batch + PowerShell + VBScript) intended to be folded into a new, unified **capture script**.  
> **What this isn’t:** a complete tool with bundled third-party binaries. You must place required EXEs in `binaries\` (see below).

---

## 🎯 Purpose

PERCIVAL automates the repetitive, platform-aware steps of **host triage** so you can integrate it into a single capture tool:

- Environment/OS detection & legacy fallbacks  
- Tool dispatch (built-ins, Sysinternals, memory capture, KAPE)  
- Artifact collection (volatile + non-volatile)  
- Structured output tree & logs (timestamped per host)

Example prior runs show per-host, timestamped output directories for CHIRON and LEGACY modes, which PERCIVAL mirrors in its own `Collection\` tree. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

---

## 📦 What’s Included (automation only)

- **PERCIVAL.bat** — main orchestrator (calls modules, writes logs, builds output paths)
- **COMMON.ps1** — shared functions invoked by batch wrappers
- **SLEEP.vbs** — lightweight delay helper for sequencing
- **Config files** — `path.txt`, `mpath.txt`, `folder.txt`, `mfolder.txt` (define `home`, `binaries`, `collection`, etc.)
- **Aux** — `tracker.txt`, `z.lnk` (workflow helpers/shortcuts)

> The automation **calls** external binaries; it **does not include** them.

---

## 🧱 Output Layout (typical)

PERCIVAL writes to a per-run, per-host folder under `D:\WORK\PERCIVAL\Collection\` with a mode suffix (e.g., `--LEGACY`, `--CHIRON`). Prior runs also show:
- **Memory dumps** (`*.zdmp`) under the host’s collection folder, indicating a memory-capture step. :contentReference[oaicite:2]{index=2}  
- **KAPE exports** (e.g., `*_KAPE.vhdx`) alongside other artifacts when KAPE is invoked. :contentReference[oaicite:3]{index=3}  
- Mode labels `CHIRON` / `LEGACY` in run markers (PERCIVAL uses the same concept). :contentReference[oaicite:4]{index=4}

Example paths seen in prior collections:  
- `D:\WORK\PERCIVAL\Collection\Computername--2021.02.02.10.46.--LEGACY\...\*.zdmp` :contentReference[oaicite:5]{index=5}  
- `D:\WORK\PERCIVAL\Collection\Computername--2021.02.02.07.01.--CHIRON\2021-02-02T150930_DESKTOP-53A1R7F_KAPE.vhdx` :contentReference[oaicite:6]{index=6}

---

## 🧭 Supported Targets

Legacy Windows through modern Windows:
- **XP/2003 (legacy mode)** — VBScript/`eventquery.vbs` fallbacks; avoid `wevtutil`/newer PowerShell.
- **Vista/7/8/10/11/Server** — fuller use of `wevtutil`, Task Scheduler XML, and PowerShell.

---

## 🔐 Chain of Custody & Integrity

- Session log per run (timestamped) is written into the host’s folder.  
- Recommended: per-file hashes (MD5/SHA256) + a manifest CSV.  
  - For performance reasons, finalize hashing on the analysis workstation if the host is slow.

---

## 🧰 Required Binaries / EXEs

PERCIVAL relies on **Windows built-ins** and **third-party tools** you must place in `binaries\`.  
Filenames below are what the automation scripts typically expect.

---

### 1) Built-in (no need to ship)

- `cmd.exe`  
- `reg.exe`  
- `sc.exe`  
- `tasklist.exe`  
- `net.exe`  
- `netstat.exe`  
- `ipconfig.exe`  
- `arp.exe`  
- `route.exe`  
- `wmic.exe` (XP SP2+)  
- `schtasks.exe`, `wevtutil.exe` (Vista+)  
- `vssadmin.exe`  
- `eventquery.vbs` (XP/2003 fallback)

---

### 2) Memory Capture (choose one, must match your batch call)

- `winpmem.exe`  
- `dumpit.exe`  
- `belkasoft_ramcapture.exe`  

> Prior PERCIVAL collections include memory dumps (`*.zdmp`), confirming this step is invoked.

---

### 3) Sysinternals (selected)

- `handle.exe`  
- `pslist.exe` **or** `psinfo.exe`  
- `psloglist.exe`  
- `autorunsc.exe`  
- `sigcheck.exe`  
- `tcpvcon.exe` *(or `tcpview.exe` with CLI export)*  

---

### 4) Archiving / Hashing

- `7z.exe` (create final ZIPs or compress subtrees)  
- `md5deep.exe` *(optional)*  
- `sha256deep.exe` *(optional)*  
  - *(Alternatively, use `certutil -hashfile` on modern Windows.)*

---

### 5) Optional Helpers

- `RawCopy.exe` (locked file copying)  
- `streams.exe` (NTFS ADS enumeration)  
- `procdump.exe` (process dumping)  
- `WinDump.exe` (packet capture)  

---

### 6) KAPE (if you use the KAPE step)

Place under `KAP\` as referenced by your config:

- `kape.exe`  
- `Modules\`  
- `Targets\`  
- `Bins\`  

> Prior artifacts show a `*_KAPE.vhdx` produced alongside other outputs.


