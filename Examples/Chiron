## 🎯 Purpose

These files automate the repetitive, platform-aware steps of **host triage** so a developer can fold them into a single new capture tool (the **“apture” script**).  

The automation handles:  
- Environment detection  
- Tool dispatch  
- Artifact collection calls  
- Output layout  
- Logging  

⚠️ **Note:** These scripts do **not** perform downstream analysis, packaging policies, or legal sign-offs that belong in the final product.

---

## 📦 What This Contains (Automation Only)

- **Orchestrator entry points** (e.g., `CHIRON.bat`)  
  Bootstraps paths, builds timestamped output directories, and calls submodules.  

- **Critical collection callers** (e.g., `CRITICAL.bat`)  
  Sequences high-value artifact collection steps.  

- **Legacy compatibility wrappers** (`LEGACYCOMMON.bat`)  
  Provides XP / 2003 fallbacks for missing PowerShell or `wevtutil`.  

- **Memory capture invoker** (`MemCap.bat`)  
  Calls a memory tool (binary must be placed in `binaries\`).  

- **KAPE integration wrapper** (`kape2.ps1`) and **operator note generator** (`Opnotes.ps1`)  

- **Config / path template** (`path.txt`)  
  Shows expected structure: `home`, `toolpath`, `binaries`, `collection`, `KAP`, and `outpath`.

---

## ⚡ Important

- The scripts assume third-party binaries live in a **`binaries\`** folder.  
- KAPE, if used, must live in a **`KAP\`** folder.  
- These scripts **call** those binaries — they do **not** include them.
