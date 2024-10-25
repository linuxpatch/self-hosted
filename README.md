
# LinuxPatch Server Appliance - Self-Hosted Patch Management

## Overview
The LinuxPatch Server Appliance is a self-hosted solution designed to simplify Linux patch management across multiple distributions. Run through a pre-built Docker image, it offers automated updates, CVE reporting, real-time alerts, and system monitoring to keep your Linux servers secure and up-to-date. The service is free for up to 3 servers, making it an ideal choice for small teams, developers, and startups.

## Features
- **Automated Patch Management**: Schedule and automate updates for seamless server maintenance.
- **AI-Powered CVE Reporting**: Get detailed insights into security vulnerabilities with automated detection.
- **Real-Time Alerts**: Receive instant notifications about critical updates and issues.
- **Integrated Healthchecks**: Monitor system performance and stability post-update.
- **Universal Compatibility**: Supports popular distributions like Ubuntu, Debian, CentOS, Rocky Linux, and more.
- **Autopilot Mode**: Set up once and let the system handle regular updates and reboots.
- **Server Grouping**: Organize servers into groups (e.g., production, staging) for easier management.
- **Scalable Deployment**: Efficiently scale from small setups to large, enterprise-level infrastructures.

## Pricing
- **Free Tier**: Manage up to 3 servers at no cost, perfect for hobbyists and small businesses.
- **Paid Plans**: Start from $1 per server per month, with custom options available for enterprises needing unlimited server management. Contact us for tailored pricing.

## Quick Start Guide

### Prerequisites
- Docker installed on your server.
- Basic knowledge of Docker commands.

### Installation
1. Clone the repository: `git clone https://github.com/linuxpatch/self-hosted.git`
2. Run the configuration script: `./configure.sh`
3. Follow the prompts to set up your server.
4. Access the web interface via `https://<your-server-ip>` (or `http://<your-server-ip>:80` if TLS is not configured).
5. To enable TLS, update TLS directives in `./data/.env` file and place your certificate at `./data/certs/server.crt` and private key at `./data/certs/server.key`.
6. Register your account and start adding servers for patch management.

## Supported Distributions
- Ubuntu (16.04+)
- Debian (8+)
- CentOS (7+)
- Rocky Linux, AlmaLinux
- Red Hat Enterprise Linux
- Amazon Linux, OpenSUSE, and more.

## Benefits
- **Secure & Compliant**: Regular updates ensure systems are always protected against vulnerabilities.
- **Ease of Use**: Simple, intuitive interface for managing server patches.
- **Time-Saving**: Automate routine updates, reducing manual intervention.
- **Flexible Deployment**: Run as a standalone Docker container for easy installation and portability.

## Contact & Support
For questions, support, or custom pricing, please contact [support@linuxpatch.com](mailto:support@linuxpatch.com).

## Why Choose LinuxPatch Server Appliance?
Efficient, reliable, and scalable, LinuxPatch helps you maintain a robust patch management strategy for your Linux infrastructure. With features like intelligent reboot scheduling, detailed vulnerability reports, and customizable alerts, you can streamline server maintenance and improve security compliance.

## Get Started Today
Secure up to 3 servers for free and explore all the benefits of automated Linux patch management.