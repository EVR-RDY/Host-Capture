# Host Capture — Forensic Collection & Processing Framework

**Host Capture** is a development project to build a two-part forensic tool:  

1. **Capture Module** — a stand-alone utility that gathers artifacts directly from a host, run from removable media (USB/drive).  
2. **Processing Module** — a follow-on workflow that processes those artifacts inside **Rampart** for parsing, enrichment, and forensic analysis.  

---

## 🎯 Purpose

Incident response and forensic investigations require both **fast capture** in the field and **structured processing** back in the lab.  
**Host Capture** unifies these into one workflow:  

- Portable, repeatable artifact collection on Windows hosts.  
- Consistent, timestamped evidence folders for chain of custody.  
- Automated import into Rampart for signature checks, hashing, parsing, and packaging.  

---

## 🧩 Architecture

### 1. Capture Module
- Run directly from trusted removable media.  
- Collect volatile state: processes, services, logged-in users, network connections.  
- Gather non-volatile artifacts: registry hives, event logs, startup items, AppCompatCache, etc.  
- Optional memory capture if supported binaries are present.  
- Write artifacts into a timestamped, host-labeled folder.  

### 2. Processing Module (Rampart)
- Ingest captured folders into Rampart.  
- Run sigcheck, hashing, ADS scans, and basic DFIR parsers.  
- Export structured outputs (CSV, JSON, VHDX).  
- Package results into verified archives for long-term storage.  

---

## 📂 Repository Purpose

This repo holds the **automation scripts, configs, and wrappers** used to build Host Capture.  

- Capture logic evolves from earlier tools (CHIRON, PERCIVAL, TERO).  
- Processing logic integrates directly with Rampart.  
- Third-party binaries (Sysinternals, FTK Imager, KAPE, etc.) are not shipped here — only the automation layer.  

---

## 🚀 Usage Concept

- **Field use (USB/drive):** Run `HostCapture.bat` (or equivalent) on the target host.  
- **Lab use (Rampart):** Import the captured folder into Rampart for automated processing.  

---

## ⚠️ Notes

- Always validate and verify third-party binaries before use.  
- Ensure proper chain-of-custody documentation is maintained.  
- Use only on authorized systems as part of sanctioned investigations.  

---

## 📌 Next Steps

- [ ] Finalize capture script (stand-alone USB-safe runner).  
- [ ] Define output schema and manifest for Rampart integration.  
- [ ] Extend Rampart modules for full parsing and packaging.  
- [ ] Test workflow end-to-end across legacy and modern Windows versions.  
