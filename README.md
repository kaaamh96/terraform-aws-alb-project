# Application Load Balancer (ALB) Architecture on AWS (Terraform)

This project demonstrates how to provision and configure an **AWS Application Load Balancer (ALB)** using **Terraform** to distribute HTTP traffic across multiple **EC2 instances** spanning two **Availability Zones (AZs)** for high availability and fault tolerance.

---

## 📌 Architecture Diagram & Flow

```text
                     [ Internet Traffic ]
                              │
                              ▼
                     ┌────────────────┐
                     │  Application   │
                     │ Load Balancer  │ (Public Subnets)
                     └───────┬────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
   ┌─────────────────┐               ┌─────────────────┐
   │ Public Subnet 1 │               │ Public Subnet 2 │
   │   (AZ: us-east-1a)              │   (AZ: us-east-1b)│
   │ ┌─────────────┐ │               │ ┌─────────────┐ │
   │ │ EC2 App 1   │ │               │ │ EC2 App 2   │ │
   │ └─────────────┘ │               │ └─────────────┘ │
   └─────────────────┘               └─────────────────┘
            └────────────────┬────────────────┘
                             ▼
                    ┌─────────────────┐
                    │  Target Group   │
                    └─────────────────┘
```

1. **User Request**: Inbound HTTP requests hit the Application Load Balancer (ALB).
2. **Listener & Rules**: The ALB listener forwards traffic on Port 80 to the Target Group.
3. **Target Group Routing**: The ALB routes requests evenly across healthy EC2 instances using a round-robin strategy.
4. **Multi-AZ Resiliency**: Deploying instances across two separate Availability Zones guarantees application availability during single-AZ outages.

---

## 📂 Repository Structure

```text
TERRAFORM-AWS-ALB/
├── .terraform/
├── images/
│   ├── image1.png          # Image 1 referenced in web page
│   └── image2.png          # Image 2 referenced in web page
├── .gitignore
├── .terraform.lock.hcl
├── main.tf                 # Core Terraform resources (VPC, Subnets, ALB, EC2, SG)
├── outputs.tf              # Infrastructure outputs (ALB DNS, Instance IPs)
├── providers.tf            # AWS provider configurations
├── README.md               # Project documentation
├── terraform.tfstate
├── terraform.tfstate.backup
├── terraform.tfvars        # Input variable definitions
└── variables.tf            # Variable declarations
```

---

## 🛠️ Infrastructure Provisioned via Terraform

- **Networking**: Custom VPC with 2 Public Subnets in different AZs, an Internet Gateway, and Route Table associations.
- **Security Groups**: 
  - **ALB Security Group**: Allows inbound HTTP (Port 80) from `0.0.0.0/0`.
  - **EC2 Security Group**: Allows inbound HTTP (Port 80) restricted to the ALB Security Group, plus SSH (Port 22).
- **Compute & Load Balancing**:
  - **2 EC2 Instances**: Bootstrapped via `user_data` shell script to install Apache, download image assets from the `images/` directory, and dynamically write host details to `index.html`.
  - **Target Group & Listener**: Target group with health check attributes configured on Port 80, attached to the ALB listener.

---

## 🚀 Quickstart & Deployment

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```
2. **Review Execution Plan**:
   ```bash
   terraform plan
   ```
3. **Apply Infrastructure**:
   ```bash
   terraform apply -auto-approve
   ```

---

## 📸 Screenshots & Proof of Deployment

### 1. Terraform Apply Success


<img width="591" height="99" alt="terraform apply with output" src="https://github.com/user-attachments/assets/b70064cb-458b-4f34-90f3-c8f5ab349d05" />


---

### 2. Traffic Balanced Across Server 1 & Server 2




<img width="732" height="804" alt="Screenshot 2026-09-08 at 02 23 06" src="https://github.com/user-attachments/assets/839f96af-6245-45e9-9363-35381bf209c1" />
<img width="721" height="789" alt="Screenshot 2026-09-08 at 02 22 40" src="https://github.com/user-attachments/assets/6557293f-087d-4ff6-a60e-8a626b0cd2a4" />


---

