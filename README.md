# 🖥️ windows-core-infra

**Infrastructure automation project based on Windows Server Core + Kubernetes + PowerShell DSC.**

This project demonstrates how to deploy and manage **Windows Server Core 2022** virtual machines inside a **Kubernetes cluster** using **KubeVirt** and configure them using **PowerShell Desired State Configuration (DSC)**.

---

## 📌 Key Technologies

- **Kubernetes** + **KubeVirt** — to run Windows VMs inside a K8s cluster
- **PowerShell DSC** — to automate server setup and configuration
- **CDI** (Containerized Data Importer) — to load Windows Server Core images
- **virtctl** — CLI tool to manage virtual machines
- **Ubuntu 24.04** — base OS for Kubernetes environment

---

## 📄 What It Does

- Launches Windows Server Core as a VM inside a K8s cluster  
- Uses Persistent Volumes or DataVolumes to import ISO/QCOW2 images  
- Configures each server via DSC scripts (hostname, services, networking)  
- Ideal for infrastructure-as-code and DevOps practice in Windows environments

---

## 📖 Full Documentation

More details, installation steps, and visuals are available in Notion:

🔗 [Notion — Windows Server Core Kubernetes Project](https://www.notion.so/Project-Windows-Server-Core-Kubernetes-245facfcf8818030a4fbfb412409c2f6)

---

## 🚀 Use Cases

- DevOps automation practice for Windows-based systems  
- Homelab or testing Windows workloads in Kubernetes  
- Learning KubeVirt, DSC, and hybrid infrastructure setup

---

> _This project is actively maintained as a learning & automation experiment._