# Workspaces Core Images  

⚠️ **Internal Use Only**  
This repository and its documentation are strictly intended for **Netweb Technologies India Ltd. Administrators**. Do not share outside the organization.  

---

## Introduction  

This repository contains the **base or “Core” images** from which all other Workspaces images are derived.  

- These images are based on popular Linux distributions.  
- They include all required wiring and configuration to run properly inside the Workspaces platform.  
- Although primarily intended for the platform, they may also be executed manually.  

> **Note**: When run outside the platform, certain features (e.g., audio, file uploads/downloads, microphone passthrough) are **not available**.  

---

## Running Core Images  

To start a container, use the following command:  

```bash
sudo docker run --rm -it --shm-size=512m -p 6901:6901   -e VNC_PW=password   --build-arg START_XFCE4=1  harbor.local/skylus-workspaces/<image>:<tag>
```

Once launched, the container can be accessed via a browser at:  

```
https://<IP>:6901
```

- **User**: `kasm_user`  
- **Password**: `password`  

---

## About Workspaces  

Workspaces is a **docker container streaming platform** that enables browser-based access to:  

- Desktops  
- Applications  
- Web services  

It leverages **Containerized Desktop Infrastructure (CDI)** technology to deliver:  

- On-demand  
- Disposable  
- Docker containers  

These containers are rendered directly in the browser using the internal **VNC service**.  

### Key Characteristics  

- **Scalable** – designed to handle demanding enterprise workloads.  
- **Customizable** – adaptable for unique organizational requirements.  
- **Maintainable** – follows a modern DevOps approach for ease of updates and deployment.  
- **Developer-Friendly** – includes an API for seamless integration with existing workflows and applications.  

---

## Deployment Options  

Workspaces supports multiple deployment models to meet operational and security requirements:  

- **Cloud** (public or private)  
- **On-Premise** (including air-gapped networks)  
- **Hybrid Configurations**  

---