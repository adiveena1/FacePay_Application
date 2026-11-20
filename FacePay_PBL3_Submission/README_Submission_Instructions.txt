================================================================================
FACEPAY — PBL-3 (CSP-391) SUBMISSION GUIDE & EVALUATION INSTRUCTIONS
Department of Computer Science & Engineering
Sharda School of Computing Science and Engineering, Sharda University
================================================================================

PROJECT DETAILS:
• Title: FacePay — Mandatory On-Device Facial Verification for Secure High-Value UPI Transactions
• Course: Project Based Learning-3 (PBL-3) Lab (CSP-391) | Semester 5 (2026-2027)
• Section: CSJ (Group G2)
• Team Members:
    1. Aditya Veena   | System ID: 2024424251 | Roll No: 2401010053 (Lead Developer)
    2. Gaurav Mudgal  | System ID: 2024278918 | Roll No: 2401010247 (Architecture Lead)
• Faculty Guide / Supervisor: Dr. Gaurav Raj, Associate Professor, Dept. of CSE

--------------------------------------------------------------------------------
1. DIRECTORY STRUCTURE & DELIVERABLES INVENTORY
--------------------------------------------------------------------------------
All submission files are organized inside this directory:
FacePay_Application/FacePay_PBL3_Submission/

├── 01_IEEE_Research_Paper.docx
├── 01_IEEE_Research_Paper.pdf
│   └── Formal 6-page IEEE-format research manuscript complete with verified
│       citations, Lok Sabha fraud statistics (₹981 Cr), mathematical models,
│       and 8/8 passing Flutter test suite results.
│       >>> THIS IS YOUR PRIMARY INTENDED PBL-3 OUTCOME FOR UPLOAD <<<
│
├── 02_Patent_Invention_Disclosure.docx
├── 02_Patent_Invention_Disclosure.pdf
│   └── 5-page formal Invention Disclosure Form (IDF) for Sharda University IPR Cell
│       and Patent Counsel, including statutory disclaimers, 5 draft claims,
│       technical flow, and Indian Patent Office (IPO) filing instructions.
│
├── 03_Authentic_Hackathon_Certificate_Aditya.pdf
│   └── Verified authentic Certificate of Participation (Cert # AIH-1-4-000210)
│       awarded to Aditya Veena Maharaj for AI Mobile Hackathon Season 1 (21 June 2026).
│
├── 03_Hackathon_Certificate_Request.docx
│   └── Audit report documenting verified certificate status and providing a formal,
│       professional letter template addressed to organizer Anand Gaur requesting
│       co-developer issuance for Gaurav Mudgal.
│
├── 04_Rubric_3_For_Signature.docx
├── 04_Rubric_3_For_Signature.pdf
│   └── Exact Sharda University Rubric #R3: Evaluation - 3 form, pre-filled with verified
│       project title, student details, software stack, and Dr. Gaurav Raj's name,
│       with marks and signature fields left clean for the evaluators.
│
├── 05_Final_Project_Report.docx
├── 05_Final_Project_Report.pdf
│   └── Comprehensive 27-page B.Tech Capstone Project Report structured across all 32
│       formal academic sections (cover, certificate, declaration, abstract, TOC,
│       system architecture, UML use case, Level 1 DFD, activity flow, module breakdown,
│       Flutter test matrix, limitations, and code appendix).
│
├── 06_Originality_Review_Report.docx
├── 06_Originality_Review_Report.pdf
│   └── 3-page internal originality & source provenance audit report, containing a 10-point
│       verified citation checklist and university Turnitin submission protocol.
│       (Does not fabricate fake similarity percentages).
│
├── 07_Submission_Checklist.docx
├── 07_Submission_Checklist.pdf
│   └── Audit checklist mapping every deliverable to its completion status and
│       Rubric 3 evaluation criteria (PO1-PO12, PSO1-PSO3).
│
└── README_Submission_Instructions.txt
    └── This document.

--------------------------------------------------------------------------------
2. STEP-BY-STEP GOOGLE FORM SUBMISSION INSTRUCTIONS
--------------------------------------------------------------------------------
When filling out the college PBL-3 Google Form:

1. Project Title:
   FacePay: Mandatory On-Device Facial Verification for Secure High-Value UPI Transactions

2. Team Members:
   Student 1: Aditya Veena (System ID: 2024424251, Roll No: 2401010053)
   Student 2: Gaurav Mudgal (System ID: 2024278918, Roll No: 2401010247)

3. PBL Outcome Option Selection:
   • Choose: "1. Research Paper in IEEE format"
   • File to Upload under Outcome:
     Upload: `01_IEEE_Research_Paper.pdf`
   (Note: Do not select multiple outcomes on the form unless explicitly requested).

4. Project Report Upload Field:
   Upload: `05_Final_Project_Report.pdf`

5. Rubric Upload Field:
   Print `04_Rubric_3_For_Signature.pdf`, obtain physical marks and signatures
   from Dr. Gaurav Raj during the viva, scan to PDF, and upload.

6. Plagiarism Report Field:
   Submit `05_Final_Project_Report.docx` to Dr. Gaurav Raj or the Sharda Central
   Library to run on official Turnitin/DrillBit, and upload the resulting PDF.
   You can attach `06_Originality_Review_Report.pdf` as internal evidence.

--------------------------------------------------------------------------------
3. PHYSICAL PRINTING & VIVA-VOCE PREPARATION
--------------------------------------------------------------------------------
Before attending your viva-voce evaluation:

1. Print 2 or 3 Hard Copies:
   • Print `05_Final_Project_Report.pdf` (spiral or hard bound as per department rules).
   • Print `01_IEEE_Research_Paper.pdf` (double-sided on high quality bond paper).
   • Print `04_Rubric_3_For_Signature.pdf` on clean A4 paper for faculty grading.
   • Print `07_Submission_Checklist.pdf` as an executive overview sheet.

2. Have Your Flutter App Ready for Live Demonstration:
   • Ensure your Android test device has the Flutter build installed (`flutter run`).
   • Test Case 1 Demo: Scan QR with amount <= ₹500 (e.g. ₹150) -> Shows direct payment flow.
   • Test Case 2 Demo: Scan QR with amount > ₹500 (e.g. ₹750) -> Triggers camera and face
     liveness challenge (blink + head turn).
   • Test Case 3 Demo: Show local transaction ledger and gamified security streak badge.

3. Key Talking Points for Evaluators (Rubric Alignment):
   • "All biometric processing is 100% on-device using Google ML Kit Vision."
   • "Zero camera images or facial templates are stored or sent to any server (DPDP Act compliant)."
   • "We do not claim live UPI banking connection; we use an authentic sandbox payment flow."
   • "The current build enforces liveness (presentation attack detection). Deep identity matching
     via MobileFaceNet embeddings is our designated future scope."
   • "Automated test suite (`flutter test`) passed with 8 out of 8 unit & widget tests."

================================================================================
Generated by AI Academic Documentation Assistant | Sharda University PBL-3
================================================================================
