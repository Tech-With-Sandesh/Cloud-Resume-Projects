# Resume Points — Project 11: AWS IAM Security

---

## Fresher

- Designed least-privilege IAM policies: Developer policy (EC2 read-only, S3 scoped to dev-team-bucket, CloudWatch Logs read) with an explicit DENY on all resources tagged `Environment=production`.
- Implemented MFA enforcement policy using `BoolIfExists: aws:MultiFactorAuthPresent: false` condition — blocks all API actions except MFA device setup until the user registers an MFA device.
- Configured a cross-account IAM role trust policy requiring both MFA presence (`aws:MultiFactorAuthPresent: true`) and source IP allowlisting — temporary credentials expire automatically after the session.
- Created a ReadOnly policy with explicit DENY on all write actions (Create*, Delete*, Modify*) — defence-in-depth ensuring read-only access even if future Allow policies are accidentally attached.

---

## Experienced Cloud Engineer

- Applied AWS IAM policy evaluation logic (Explicit Deny > Allow > Implicit Deny) to design defence-in-depth policies: developer policy allows scoped access, production environment tag-based DENY overrides any Allow, MFA enforcement denies everything without MFA — three independent layers of access control.
- Implemented `BoolIfExists` condition operator for MFA enforcement (not `Bool`) — `BoolIfExists` correctly handles API calls where the MFA key is absent from the request context (e.g., long-lived access key calls), treating absence as false.
- Designed cross-account role assumption with dual conditions: MFA required (`aws:MultiFactorAuthPresent: true`) + source IP CIDR allowlist (`aws:SourceIp`) — ensuring cross-account access is possible only from corporate offices with MFA authenticated sessions.
- Documented IAM Identity Center (AWS SSO) for federation, AWS Organizations SCP for account-level guardrails, CloudTrail + CloudWatch for IAM event alerting, and AWS Config rules for compliance checking.

---

## LinkedIn Project Description

Designed a production-grade AWS IAM security architecture: Developer policy (EC2 read-only, scoped S3, explicit DENY on Environment=production tagged resources), ReadOnly policy (explicit write action DENY for defence-in-depth), MFA enforcement policy (DenyAll without MFA using BoolIfExists condition), cross-account role trust policy (MFA + source IP conditions). Documented IAM Identity Center, SCP, CloudTrail alerting, and Config compliance rules as production patterns.

---

## GitHub Project Description

AWS IAM Security (JSON Policies) — Developer policy (scoped S3/EC2/CloudWatch + production DENY), ReadOnly policy (explicit write DENY), MFA enforcement (BoolIfExists condition), cross-account role trust (MFA + IP conditions). Production: IAM Identity Center, SCP, CloudTrail, Config rules.

---

## How to Explain in an Interview (30 Seconds)

"I designed a multi-layer IAM security setup. The developer policy allows scoped access to dev resources — but there's an explicit DENY on any resource tagged as production. In IAM, explicit Deny always wins over Allow, so even if a developer has S3 permissions, they can't touch production S3 buckets. I also built MFA enforcement using the BoolIfExists condition — this blocks every API call if MFA isn't present, except for the actions needed to set up MFA itself. BoolIfExists is important because with the regular Bool condition, users with long-lived access keys could bypass it since MFA context isn't in their requests."

---

## Skills Demonstrated

- IAM policy evaluation logic (Explicit Deny > Allow > Implicit Deny)
- Least-privilege IAM (scoped actions, scoped resources)
- Resource-based conditions (aws:ResourceTag, Environment=production DENY)
- MFA enforcement policy (BoolIfExists vs Bool — handling missing context keys)
- Cross-account IAM roles (sts:AssumeRole, trust policy)
- Trust policy conditions (MFA + IP address allowlisting)
- NotAction element (deny all except listed actions pattern)
- Explicit DENY for write actions (defence-in-depth for read-only)
- IAM groups and users (permission assignment via group membership)
- AWS IAM Identity Center (SSO — production upgrade path)
- AWS Organizations SCP (account-level guardrails)
- CloudTrail + Config for IAM compliance monitoring
