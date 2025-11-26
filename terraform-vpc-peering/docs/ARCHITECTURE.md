# VPC Peering Architecture

## 🏗️ Network Topology

```
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS Region (us-east-1)                      │
│                                                                      │
│  ┌──────────────────────────────┐  ┌──────────────────────────────┐│
│  │  VPC 1 (Production)          │  │  VPC 2 (Development)         ││
│  │  CIDR: 10.1.0.0/16           │  │  CIDR: 10.2.0.0/16           ││
│  │  65,536 IP addresses         │  │  65,536 IP addresses         ││
│  │                              │  │                              ││
│  │  ┌────────────────────────┐  │  │  ┌────────────────────────┐ ││
│  │  │ Subnet                 │  │  │  │ Subnet                 │ ││
│  │  │ CIDR: 10.1.1.0/24      │  │  │  │ CIDR: 10.2.1.0/24      │ ││
│  │  │ 256 IP addresses       │  │  │  │ 256 IP addresses       │ ││
│  │  │ AZ: us-east-1a         │  │  │  │ AZ: us-east-1a         │ ││
│  │  └────────────────────────┘  │  │  └────────────────────────┘ ││
│  │                              │  │                              ││
│  │  ┌────────────────────────┐  │  │  ┌────────────────────────┐ ││
│  │  │ Route Table            │  │  │  │ Route Table            │ ││
│  │  │ ─────────────────────  │  │  │  │ ─────────────────────  │ ││
│  │  │ 0.0.0.0/0 → IGW        │  │  │  │ 0.0.0.0/0 → IGW        │ ││
│  │  │ 10.2.0.0/16 → Peering  │  │  │  │ 10.1.0.0/16 → Peering  │ ││
│  │  └────────────────────────┘  │  │  └────────────────────────┘ ││
│  │                              │  │                              ││
│  │  ┌────────────────────────┐  │  │  ┌────────────────────────┐ ││
│  │  │ Security Group         │  │  │  │ Security Group         │ ││
│  │  │ ─────────────────────  │  │  │  │ ─────────────────────  │ ││
│  │  │ Inbound:               │  │  │  │ Inbound:               │ ││
│  │  │  - SSH (22) from 0/0   │  │  │  │  - SSH (22) from 0/0   │ ││
│  │  │  - All from 10.2.0.0/16│  │  │  │  - All from 10.1.0.0/16│ ││
│  │  │  - ICMP from 10.2.0.0  │  │  │  │  - ICMP from 10.1.0.0  │ ││
│  │  │ Outbound:              │  │  │  │ Outbound:              │ ││
│  │  │  - All traffic         │  │  │  │  - All traffic         │ ││
│  │  └────────────────────────┘  │  │  └────────────────────────┘ ││
│  │                              │  │                              ││
│  │  ┌────────────────────────┐  │  │  ┌────────────────────────┐ ││
│  │  │ Internet Gateway       │  │  │  │ Internet Gateway       │ ││
│  │  └──────────┬─────────────┘  │  │  └──────────┬─────────────┘ ││
│  └─────────────┼────────────────┘  └─────────────┼───────────────┘│
│                │                                  │                │
│                │                                  │                │
│                └──────────────┬───────────────────┘                │
│                               │                                    │
│                    ┌──────────▼──────────┐                         │
│                    │  VPC Peering        │                         │
│                    │  Connection         │                         │
│                    │  Status: Active     │                         │
│                    │  Type: Intra-region │                         │
│                    └─────────────────────┘                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                               │
                               │ Internet
                               ▼
                        ┌──────────────┐
                        │   Internet   │
                        │    Users     │
                        └──────────────┘
```

## 🔄 Traffic Flow

### Scenario 1: Instance in VPC 1 → Internet

```
EC2 (VPC 1) → Route Table → Internet Gateway → Internet
10.1.1.10      0.0.0.0/0
```

### Scenario 2: Instance in VPC 1 → Instance in VPC 2

```
EC2 (VPC 1) → Route Table → VPC Peering → Route Table → EC2 (VPC 2)
10.1.1.10      10.2.0.0/16   Connection    10.1.0.0/16    10.2.1.20
```

### Scenario 3: Internet → Instance in VPC 1

```
Internet → Internet Gateway → Route Table → EC2 (VPC 1)
                                             10.1.1.10
```

## 📊 Resource Relationships

```
VPC 1
  ├── Subnet 1
  │   └── Route Table Association
  ├── Internet Gateway
  ├── Route Table
  │   ├── Route to Internet (0.0.0.0/0 → IGW)
  │   └── Route to VPC 2 (10.2.0.0/16 → Peering)
  └── Security Group
      ├── Ingress: SSH from anywhere
      ├── Ingress: All from VPC 2
      └── Egress: All traffic

VPC 2
  ├── Subnet 2
  │   └── Route Table Association
  ├── Internet Gateway
  ├── Route Table
  │   ├── Route to Internet (0.0.0.0/0 → IGW)
  │   └── Route to VPC 1 (10.1.0.0/16 → Peering)
  └── Security Group
      ├── Ingress: SSH from anywhere
      ├── Ingress: All from VPC 1
      └── Egress: All traffic

VPC Peering Connection
  ├── Requester: VPC 1
  ├── Accepter: VPC 2
  └── Status: Active (auto-accepted)
```

## 🎯 IP Address Allocation

### VPC 1 (10.1.0.0/16)
- **Total IPs**: 65,536
- **Subnet 1 (10.1.1.0/24)**: 256 IPs
  - **AWS Reserved**: 5 IPs (.0, .1, .2, .3, .255)
  - **Available**: 251 IPs
- **Remaining**: 65,280 IPs for additional subnets

### VPC 2 (10.2.0.0/16)
- **Total IPs**: 65,536
- **Subnet 2 (10.2.1.0/24)**: 256 IPs
  - **AWS Reserved**: 5 IPs (.0, .1, .2, .3, .255)
  - **Available**: 251 IPs
- **Remaining**: 65,280 IPs for additional subnets

## 🔐 Security Architecture

### Defense in Depth

```
Layer 1: Network ACLs (Default - Allow All)
         ↓
Layer 2: Security Groups (Configured)
         ↓
Layer 3: Instance Firewall (Optional)
         ↓
Layer 4: Application Security
```

### Security Group Rules

**VPC 1 Security Group**:
```
Inbound:
  - Port 22 (SSH) from 0.0.0.0/0
  - All ports from 10.2.0.0/16
  - ICMP from 10.2.0.0/16

Outbound:
  - All traffic to 0.0.0.0/0
```

**VPC 2 Security Group**:
```
Inbound:
  - Port 22 (SSH) from 0.0.0.0/0
  - All ports from 10.1.0.0/16
  - ICMP from 10.1.0.0/16

Outbound:
  - All traffic to 0.0.0.0/0
```

## 📈 Scalability

### Current Setup
- 2 VPCs
- 2 Subnets (1 per VPC)
- 1 Peering Connection

### Possible Expansions
- Add more subnets (public/private)
- Add NAT Gateways for private subnets
- Add VPC Endpoints for AWS services
- Add additional VPCs and peering connections
- Implement Transit Gateway for hub-and-spoke

## 💰 Cost Breakdown

| Resource | Quantity | Cost |
|----------|----------|------|
| VPC | 2 | Free |
| Subnet | 2 | Free |
| Internet Gateway | 2 | Free |
| Route Table | 2 | Free |
| Security Group | 2 | Free |
| VPC Peering (same region) | 1 | Free |
| **Data Transfer** | - | **$0.01/GB** |

**Total Infrastructure Cost**: $0

**Data Transfer Costs**:
- Within same AZ: Free
- Between AZs: $0.01/GB
- To Internet: $0.09/GB (first 10TB)

## 🎓 Key Concepts

### VPC Peering Characteristics
- ✅ **One-to-one**: Each peering connects exactly two VPCs
- ✅ **Non-transitive**: A↔B and B↔C doesn't mean A↔C
- ✅ **Same or different regions**: Can peer across regions
- ✅ **Same or different accounts**: Can peer across AWS accounts
- ❌ **No overlapping CIDRs**: CIDR blocks must be unique
- ❌ **No edge-to-edge routing**: Can't route through peered VPC

### Route Table Logic
```
Destination: 10.1.1.50 (in VPC 1)
Source: 10.2.1.30 (in VPC 2)

VPC 2 Route Table checks:
  - 10.1.1.50 matches 10.1.0.0/16 → Use Peering Connection
  
VPC 1 receives packet and routes to 10.1.1.50
```

### Security Group Evaluation
```
Packet from 10.2.1.30 → 10.1.1.50:22

VPC 1 Security Group checks:
  - Source: 10.2.1.30 (in 10.2.0.0/16) ✓
  - Destination Port: 22 ✓
  - Protocol: TCP ✓
  
Result: ALLOW
```

## 🔍 Monitoring Points

### CloudWatch Metrics
- VPC Flow Logs (traffic analysis)
- VPC Peering metrics (data transfer)
- Security Group metrics (rejected packets)

### Key Metrics to Monitor
- Bytes In/Out across peering
- Packets In/Out across peering
- Rejected connections (security groups)
- Route table changes

## 🎯 Best Practices

1. **CIDR Planning**: Plan CIDR blocks carefully to avoid overlap
2. **Security Groups**: Use least privilege principle
3. **Route Tables**: Keep routes simple and documented
4. **Tagging**: Tag all resources for organization
5. **Monitoring**: Enable VPC Flow Logs
6. **Documentation**: Document peering relationships
7. **Testing**: Test connectivity after setup

---

**Next Steps**: See `README.md` for deployment instructions
