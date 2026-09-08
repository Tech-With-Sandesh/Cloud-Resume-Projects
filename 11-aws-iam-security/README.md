# Project 11 - AWS IAM Security: Least Privilege Policies, MFA Enforcement and Cross-Account Roles

## Problem Statement

Your organisation needs a secure IAM structure for an engineering team with:
- Developers access only dev resources (not production)
- Read-only access for auditors and QA engineers
- MFA enforcement — all API calls blocked without MFA
- Cross-account access via role assumption (no permanent credentials)
- No long-lived access keys for human users

Build a production-grade IAM security setup following AWS security best practices.

---

## Architecture

```
IAM Users
  ├── Developer Group    → developer-policy.json
  │     ├── EC2 read-only
  │     ├── S3 access (dev-team-bucket only)
  │     ├── CloudWatch Logs (read)
  │     └── DENY all resources tagged Environment=production
  │
  ├── ReadOnly Group     → readonly-policy.json
  │     └── Describe*/List* only — explicit DENY on all write actions
  │
  └── All Users          → mfa-enforce-policy.json
        └── DENY everything except MFA setup if MFA not present

Cross-Account Access:
  Trusted Account → sts:AssumeRole → Target Account ReadOnly Role
  (Conditions: MFA required + source IP restriction)
```

---

## Project Structure

```
11-aws-iam-security/
└── policies/
    ├── developer-policy.json      ← Dev access, prod environment DENY
    ├── readonly-policy.json       ← Read-only + explicit write DENY
    ├── mfa-enforce-policy.json    ← Block all API without MFA
    └── cross-account-role.json    ← Trust policy (MFA + IP conditions)
```

---

## Prerequisites

- AWS Account with admin access
- AWS CLI configured

---

## Step 1 — Create IAM Groups and Attach Policies

### Create Developer Policy

```bash
aws iam create-policy \
  --policy-name DeveloperPolicy \
  --policy-document file://policies/developer-policy.json
```

### Create ReadOnly Policy

```bash
aws iam create-policy \
  --policy-name ReadOnlyPolicy \
  --policy-document file://policies/readonly-policy.json
```

### Create MFA Enforcement Policy

```bash
aws iam create-policy \
  --policy-name MFAEnforcePolicy \
  --policy-document file://policies/mfa-enforce-policy.json
```

---

## Step 2 — Create Groups

```bash
aws iam create-group --group-name Developers
aws iam create-group --group-name ReadOnly

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws iam attach-group-policy \
  --group-name Developers \
  --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/DeveloperPolicy"

aws iam attach-group-policy \
  --group-name ReadOnly \
  --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/ReadOnlyPolicy"
```

---

## Step 3 — Create a Developer User

```bash
aws iam create-user --user-name alice

aws iam add-user-to-group --user-name alice --group-name Developers

# Attach MFA enforcement at user level
aws iam attach-user-policy \
  --user-name alice \
  --policy-arn "arn:aws:iam::$ACCOUNT_ID:policy/MFAEnforcePolicy"

# Create console password (force reset on first login)
aws iam create-login-profile \
  --user-name alice \
  --password "TempPass123!" \
  --password-reset-required
```

---

## Step 4 — Create Cross-Account Role

Update `cross-account-role.json` with the trusted account ID:

```bash
sed 's/TRUSTED-ACCOUNT-ID/123456789012/' policies/cross-account-role.json > /tmp/trust-policy.json

aws iam create-role \
  --role-name CrossAccountReadOnly \
  --assume-role-policy-document file:///tmp/trust-policy.json

aws iam attach-role-policy \
  --role-name CrossAccountReadOnly \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess
```

---

## Step 5 — Test the MFA Enforcement

Log in as alice without MFA and try to list EC2 instances:

```bash
aws ec2 describe-instances --profile alice
```

Expected:

```
An error occurred (AccessDenied) when calling the DescribeInstances operation:
User: arn:aws:iam::123456789012:user/alice is not authorized to perform: ec2:DescribeInstances
```

After alice sets up MFA, the request succeeds.

---

## Step 6 — Test Production Resource Block

Tag an EC2 instance with `Environment=production` and try to access it as alice:

```bash
aws ec2 terminate-instances --instance-ids i-0prodinstance123 --profile alice
```

Expected (even if developer policy allows EC2 actions):

```
An error occurred (AccessDenied): Explicit deny in a policy
```

---

## Step 7 — Test Cross-Account Role Assumption

From the trusted account:

```bash
aws sts assume-role \
  --role-arn "arn:aws:iam::TARGET-ACCOUNT-ID:role/CrossAccountReadOnly" \
  --role-session-name "AuditSession" \
  --serial-number arn:aws:iam::TRUSTED-ACCOUNT-ID:mfa/your-mfa-device \
  --token-code 123456
```

Expected — temporary credentials returned:

```json
{
  "Credentials": {
    "AccessKeyId": "ASIA...",
    "SecretAccessKey": "...",
    "SessionToken": "...",
    "Expiration": "2024-01-15T12:30:00Z"
  }
}
```

---

## Verification Checklist

✅ DeveloperPolicy created and attached to Developers group

✅ ReadOnlyPolicy created with explicit write DENY

✅ MFAEnforcePolicy blocks all actions when MFA not present

✅ Developer cannot access resources tagged `Environment=production`

✅ Cross-account role requires MFA + source IP

✅ User alice can set up MFA device before any API access

✅ No long-lived access keys created for human users

---

## Troubleshooting

**`AccessDenied` even for allowed actions:**
- Check policy evaluation order: DENY always wins over ALLOW
- Use IAM Policy Simulator (`iam:SimulatePrincipalPolicy`) to test

**MFA enforce policy not blocking:**
- Verify `BoolIfExists` condition (not `Bool`) — `BoolIfExists` handles cases where MFA key is absent entirely

**Cross-account role assumption fails:**
- Verify source IP in cross-account-role.json matches your actual public IP
- Ensure MFA token is current (30-second window)

---

## Production Notes

> **1. Use AWS IAM Identity Center (SSO)**
> Replace IAM users + access keys with AWS IAM Identity Center for federated SSO via Active Directory or Okta.

> **2. Enable AWS Organizations SCP**
> Apply Service Control Policies at the account level — even Admins cannot bypass SCPs.

> **3. Enable AWS CloudTrail**
> All IAM API calls are logged to CloudTrail. Set up CloudWatch Alarms on IAM events like `DeletePolicy` or `AttachRolePolicy`.

> **4. AWS Config Rules for IAM**
> Enable managed rules: `iam-root-access-key-check`, `iam-user-mfa-enabled`, `iam-no-inline-policy-check`.

---

## Key Learnings

- IAM policy evaluation logic (Explicit Deny > Allow, default Deny)
- Resource-level conditions (`aws:ResourceTag`, `aws:SourceIp`, `aws:MultiFactorAuthPresent`)
- `BoolIfExists` vs `Bool` condition operator (handles missing key)
- MFA enforcement pattern (DenyAllExcept MFA setup actions)
- Cross-account role assumption with `sts:AssumeRole`
- Trust policy with MFA + IP conditions
- Explicit DENY in readonly policy (defence-in-depth for write actions)
- `NotAction` element (deny everything except listed actions)
- IAM groups vs roles (human users vs applications/services)
- AWS IAM Identity Center (production replacement for IAM users)
- Service Control Policies (organisation-level guardrails)
