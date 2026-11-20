import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

def set_cell_background(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def add_callout(doc, text, title=None, border_color='C00000', bg_color='FFF2F2'):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = tbl.cell(0, 0)
    set_cell_background(cell, bg_color)
    set_cell_margins(cell, top=120, bottom=120, left=180, right=180)
    
    tcPr = cell._tc.get_or_add_tcPr()
    tcBorders = OxmlElement('w:tcBorders')
    
    left = OxmlElement('w:left')
    left.set(qn('w:val'), 'single')
    left.set(qn('w:sz'), '24')
    left.set(qn('w:space'), '0')
    left.set(qn('w:color'), border_color)
    tcBorders.append(left)
    
    for side in ['top', 'bottom', 'right']:
        b = OxmlElement(f'w:{side}')
        b.set(qn('w:val'), 'none')
        tcBorders.append(b)
    tcPr.append(tcBorders)
    
    p = cell.paragraphs[0]
    p.paragraph_format.line_spacing = 1.15
    p.paragraph_format.space_before = Pt(2)
    p.paragraph_format.space_after = Pt(2)
    if title:
        r_t = p.add_run(f"{title}\n")
        r_t.bold = True
        r_t.font.name = 'Arial'
        r_t.font.size = Pt(10)
        r_t.font.color.rgb = RGBColor(0xC0, 0x00, 0x00)
    r = p.add_run(text)
    r.font.name = 'Arial'
    r.font.size = Pt(9.5)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

def build_patent_idf(output_path):
    doc = docx.Document()
    
    for s in doc.sections:
        s.top_margin = Inches(1.0)
        s.bottom_margin = Inches(1.0)
        s.left_margin = Inches(1.0)
        s.right_margin = Inches(1.0)
        
        footer = s.footer
        fp = footer.paragraphs[0]
        fp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        fr = fp.add_run("FORMAL INVENTION DISCLOSURE (IDF) | SHARDA UNIVERSITY IPR CELL")
        fr.font.name = 'Arial'
        fr.font.size = Pt(8.5)
        fr.font.color.rgb = RGBColor(0x7F, 0x7F, 0x7F)

    # University Header
    p_inst = doc.add_paragraph()
    p_inst.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_inst = p_inst.add_run("SHARDA UNIVERSITY â€” INTELLECTUAL PROPERTY RIGHTS (IPR) CELL\n")
    r_inst.font.name = 'Arial'
    r_inst.font.size = Pt(12)
    r_inst.font.bold = True
    r_inst.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
    
    r_sub = p_inst.add_run("INVENTION DISCLOSURE FORM (IDF) FOR PATENT EVALUATION\n(Academic & Student Innovation Track â€” PBL-3 Capstone Outcome)")
    r_sub.font.name = 'Arial'
    r_sub.font.size = Pt(10)
    r_sub.font.italic = True
    p_inst.paragraph_format.space_after = Pt(12)

    # Mandatory Legal Notice Box
    add_callout(
        doc,
        "LEGAL NOTICE & STATUTORY DISCLAIMER:\n"
        "This document constitutes an internal, technical Invention Disclosure Form (IDF) prepared for preliminary evaluation "
        "by the Sharda University Intellectual Property Rights (IPR) Cell and patent counsel. THIS DOCUMENT DOES NOT CONSTITUTE "
        "A FILED APPLICATION, GRANTED PATENT, PROVISIONAL SPECIFICATION, OR PROOF OF PATENTABILITY BEFORE THE INDIAN PATENT OFFICE (IPO) "
        "OR ANY INTERNATIONAL PATENT AUTHORITY. No patent rights are granted by the creation of this document. "
        "Formal filing requires completion of Form 1, Form 2 (Provisional/Complete Specification), Form 3, Form 5, institutional clearance "
        "by the Dean of Research, and official submission to the Patent Office under The Patents Act, 1970.",
        title="STATUTORY STATUS: DRAFT INVENTION DISCLOSURE DOCUMENT"
    )

    # Project / Invention Metadata Table
    meta_table = doc.add_table(rows=7, cols=2)
    meta_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    m_col_w = [Inches(2.5), Inches(4.0)]
    
    fields = [
        ("Proposed Invention Title", "SYSTEM AND METHOD FOR MANDATORY ON-DEVICE FACIAL LIVENESS VERIFICATION GOVERNING TRANSACTION-THRESHOLD DIGITAL PAYMENTS"),
        ("Internal Reference / Tracking", "SU/SET/CSE/PBL3/2026/IDF-FP01 (Provisional Academic Record)"),
        ("Lead Student Inventors", "1. Aditya Veena Maharaj (Roll No: 2401010053, System ID: 2024424251)\n2. Gaurav Mudgal (Roll No: 2401010247, System ID: 2024278918)"),
        ("Faculty Supervisor / In-Charge", "Dr. Gaurav Raj, Associate Professor, Dept. of Computer Science & Engineering"),
        ("Academic Institution / Affiliation", "Sharda School of Computing Science and Engineering, Sharda University, Greater Noida, UP, India"),
        ("Technical Classification (IPC / CPC)", "G06Q 20/40 (Payment Authorization / Fraud Detection)\nG06F 21/32 (Biometric Authentication Security)\nG06V 40/16 (Face Presentation Attack Detection)"),
        ("Current Development Stage", "Functional Working Prototype (Flutter Mobile Client + Edge ML Kit Vision + Payment Sandbox Engine)")
    ]

    for idx, (lbl, val) in enumerate(fields):
        row = meta_table.rows[idx]
        c0 = row.cells[0]
        c1 = row.cells[1]
        c0.width = m_col_w[0]
        c1.width = m_col_w[1]
        set_cell_background(c0, 'F2F4F7')
        set_cell_margins(c0, top=60, bottom=60, left=80, right=80)
        set_cell_margins(c1, top=60, bottom=60, left=80, right=80)
        
        p0 = c0.paragraphs[0]
        p0.paragraph_format.line_spacing = 1.1
        r0 = p0.add_run(lbl)
        r0.font.name = 'Arial'
        r0.font.size = Pt(9)
        r0.font.bold = True
        
        p1 = c1.paragraphs[0]
        p1.paragraph_format.line_spacing = 1.1
        r1 = p1.add_run(val)
        r1.font.name = 'Arial'
        r1.font.size = Pt(9)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    def add_h1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(14)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = Pt(11)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
        return p

    def add_h2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(8)
        p.paragraph_format.space_after = Pt(2)
        p.paragraph_format.keep_with_next = True
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = Pt(10)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0x33, 0x33, 0x33)
        return p

    def add_p(text, space_after=6):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.line_spacing = 1.15
        p.paragraph_format.space_after = Pt(space_after)
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = Pt(10)
        return p

    add_h1("1. TECHNICAL FIELD OF THE INVENTION")
    add_p(
        "The present invention relates generally to digital payment authorization systems and mobile cyber-security architectures. "
        "More specifically, the invention relates to systems and computer-implemented methods for enforcing dynamic, multi-tier security "
        "policies in retail digital payments, wherein on-device biometric Presentation Attack Detection (PAD)â€”comprising real-time eye-blink "
        "and head-pose Euler yaw trackingâ€”is conditionally mandated upon detecting a payment amount exceeding a predefined monetary threshold, "
        "without transmitting raw biometric image frames or identity templates over communications networks."
    )

    add_h1("2. BACKGROUND AND DEFICIENCIES OF EXISTING ART")
    add_p(
        "Modern mobile retail payments, exemplified by India's Unified Payments Interface (UPI), have achieved massive market penetration. "
        "However, existing authorization mechanisms present three severe architectural limitations:\n\n"
        "1. Vulnerability of Knowledge-Based Credentials: Conventional payment initiation relies upon a numeric Personal Identification "
        "Number (PIN) or SMS-based One-Time Password (OTP). Knowledge factors are susceptible to physical shoulder-surfing, keystroke logging, "
        "phishing websites, SIM-swap attacks, and social engineering coercion. Official Lok Sabha parliamentary reports record UPI-related fraud "
        "losses escalating to â‚¹981 Crore across 12.64 lakh incidents in FY25.\n\n"
        "2. The 'Optional Biometrics' Architectural Defect: When biometrics have been introduced in contemporary fintech apps, they are typically "
        "implemented as an optional device-unlock convenience or a merchant-configurable setting. If an adversary gains possession of an active, "
        "unlocked device, or convinces a victim to initiate a transfer, optional biometric defenses fail completely.\n\n"
        "3. Cloud Biometric Centralization vs. Micro-Payment Friction: Existing high-security biometric systems transmit facial video streams "
        "to remote servers for facial recognition. This creates systemic privacy risks, violates data localization mandates, and incurs round-trip "
        "network latency that makes everyday small transactions intolerable."
    )

    add_h1("3. OBJECT OF THE INVENTION")
    add_p(
        "The principal object of the present invention is to provide a privacy-preserving, edge-computed payment authorization system that "
        "selectively balances fraud prevention against checkout velocity. A secondary object is to eliminate server-side biometric storage "
        "by executing 100% of facial landmark classification, blink verification, and pose rotation tracking locally on the client mobile device. "
        "A further object is to habituate users to robust security practices through an integrated behavioral reward and streak mechanism."
    )

    add_h1("4. SUMMARY OF THE PROPOSED INVENTION")
    add_p(
        "The disclosed invention introduces a mobile computing architecture comprising: an Optical Ingestion Engine for decoding merchant payment requests; "
        "a Monetary Policy Threshold Engine configured with a non-bypassable threshold value ($T = â‚¹500$); an On-Device Biometric Verification Engine; "
        "and a Transaction Orchestration Engine.\n\n"
        "When a transaction amount $A$ is parsed, the system compares $A$ against $T$. If $A \\le T$, the system permits authorization to execute "
        "via baseline transaction channels without invoking camera biometrics, eliminating checkout latency for routine micro-payments. "
        "If $A > T$, the system engages a mandatory hardware lock that disables payment dispatch until an active two-stage facial liveness "
        "challenge protocol is completed. The liveness protocol evaluates live video frames entirely in local device memory using edge machine learning: "
        "(a) an eye-blink ratio transition confirming natural physiological movement, and (b) a randomized head-pose yaw rotation confirming that the user "
        "is physically interacting with the device. If liveness verification passes, a cryptographic execution token is released to the payment simulator; "
        "otherwise, the transaction is hard-aborted after a bound of retry attempts."
    )

    add_h1("5. DETAILED TECHNICAL DESCRIPTION OF THE PREFERRED EMBODIMENT")
    add_p(
        "The preferred embodiment is instantiated as a client-side mobile application constructed using the Flutter runtime framework on Android mobile devices. "
        "The system comprises five core technical subsystems:"
    )
    add_h2("A. Optical QR Code Ingestion Subsystem")
    add_p(
        "The application utilizes an optical scanner service (`QRScannerService`) interfacing with the device camera to capture and decode Quick Response (QR) codes. "
        "The service parses standard UPI URI syntax conforming to NPCI specifications: `upi://pay?pa={merchant_vpa}&pn={merchant_name}&am={amount}&cu=INR&tn={note}`. "
        "The parser extracts the Virtual Payment Address (VPA), payee entity name, transaction reference note, and pre-set transaction amount. "
        "In scenarios where the QR code omits the amount, the UI dynamically prompts the user for manual numerical amount entry."
    )
    add_h2("B. Policy Threshold Evaluation Engine")
    add_p(
        "Prior to initiating network communication or payment gateway APIs, the input amount string is passed to `PaymentValidationService`. "
        "The service executes strict sanitization: stripping currency symbols ('â‚¹'), verifying numerical formatting, rejecting non-positive values ($A \\le 0$), "
        "and validating that the amount does not exceed system bounds (â‚¹1,00,000.00). The service computes the boolean indicator:\n"
        "`requiresFaceVerification = (sanitizedAmount > 500.00)`. "
        "This boundary is hard-coded into immutable application configuration constants (`AppConstants.faceVerificationThreshold`), "
        "preventing runtime client-side tampering."
    )
    add_h2("C. Edge Biometric Liveness Verification Engine")
    add_p(
        "Upon assertion of `requiresFaceVerification = true`, the application transitions to `FaceVerificationScreen` and instantiates `FaceDetectionService`. "
        "The camera stream delivers raw YUV_420_888 image frames at 30 FPS to the local Google ML Kit FaceDetector running on the device Neural Processing Unit (NPU) or GPU. "
        "The liveness evaluation state machine (`LivenessService`) executes a sequential, deterministic multi-stage challenge:\n\n"
        "1. Single Face Centering: The detector ensures exactly one human face bounding box is present in the frame. If zero faces or multiple faces are detected, "
        "an alert state is triggered, preventing verification.\n\n"
        "2. Dual-Threshold Eye Blink Detection: The system continuously samples `leftEyeOpenProbability` ($P_L$) and `rightEyeOpenProbability` ($P_R$). "
        "A valid blink requires: (i) an initial open state where $\\min(P_L, P_R) \\ge 0.70$; (ii) a subsequent closed state where $\\max(P_L, P_R) \\le 0.25$; "
        "and (iii) a return to the open state $\\min(P_L, P_R) \\ge 0.70$. This state sequence must complete within a 15-second countdown window.\n\n"
        "3. Dynamic Head-Pose Euler Yaw Tracking: Upon blink clearance, the engine generates a directional challenge $D \\in \\{Turn Left, Turn Right\\}$. "
        "The subject must rotate their head along the vertical axis until the Euler Yaw angle $\\theta_{yaw}$ satisfies: $\\theta_{yaw} \\le -20.0^\\circ$ (for left turns) "
        "or $\\theta_{yaw} \\ge +20.0^\\circ$ (for right turns), initiated from a neutral resting state ($|\\theta_{yaw}| < 10.0^\\circ$). "
        "This dynamic physical movement requirement defeats static 2D paper printouts, cut-out masks, and static screen replay attacks."
    )
    add_h2("D. Ephemeral Memory and Privacy Preservation Architecture")
    add_p(
        "A paramount technical feature of the invention is the strict isolation of biometric data. At no point are camera image buffers saved to persistent flash "
        "memory, logged to operating system caches, or transmitted over cellular/Wi-Fi sockets. All landmark computations exist transiently in RAM and are overwritten "
        "on the subsequent frame cycle. Once the challenge passes, `LivenessService` generates an ephemeral verification token `VerificationResult(status: passed)` "
        "that is injected into the local payment orchestrator and destroyed upon transaction termination."
    )
    add_h2("E. Payment Simulation and Gamified Ledger Subsystem")
    add_p(
        "Upon receiving a verified execution token, `PaymentService` dispatches the transaction payload to the test gateway (simulated wallet or Razorpay sandbox). "
        "Upon confirmation of settlement, the local ledger appends a transaction receipt tagged with a non-repeating UUID. "
        "`RewardsService` evaluates habit-forming criteria, incrementing secure transaction streaks and granting achievements (e.g., 'Secure Shield Badge', "
        "'First Payment Milestone') stored locally in Android SharedPreferences."
    )

    add_h1("6. NOVELTY AND INVENTIVE STEP POINTS FOR PATENTABILITY EVALUATION")
    add_p(
        "The inventors submit the following technical features as candidates for patentable novelty and inventive step:\n"
        "1. Dynamic Inherence Enforcement: Unlike prior art where biometrics are permanently active or entirely optional, the present system couples biometric "
        "activation directly to a mathematical monetary transaction threshold ($A > 500.00$), establishing a context-aware security gate that eliminates checkout friction on low-value micro-transactions.\n"
        "2. Closed-Loop On-Device Presentation Attack Detection: Combining multi-state eye-blink hysteresis thresholds with active Euler yaw angle rotation challenges "
        "computed exclusively via client edge ML Kit vision, ensuring zero biometric data leakage.\n"
        "3. Anti-Coercion and Lockout State Machine: A deterministic retry limiter enforcing transaction termination upon 3 consecutive challenge failures or 15-second expiration, "
        "protecting against persistent attack vectors."
    )

    add_h1("7. PROPOSED DRAFT PATENT CLAIMS (FOR REVIEW WITH PATENT ATTORNEY)")
    add_p(
        "WE CLAIM:\n\n"
        "1. A computer-implemented method for secure payment authorization on a mobile computing device, the method comprising:\n"
        "   (a) receiving, via an optical camera sensor of the mobile computing device, a Quick Response (QR) code representing a payment transaction request;\n"
        "   (b) parsing from said QR code or a user interface input a monetary transaction amount $A$;\n"
        "   (c) comparing, via a client-side payment validation service, said monetary transaction amount $A$ against a predefined threshold value $T$;\n"
        "   (d) in response to determining that $A \\le T$, dispatching an authorization payload to a payment processing service without invoking facial biometric verification;\n"
        "   (e) in response to determining that $A > T$, locking transaction dispatch and initiating a camera stream on the mobile computing device;\n"
        "   (f) evaluating, via an on-device machine learning face detection engine, a sequence of camera frames to detect an active facial liveness challenge comprising an eye-blink transition and a head-pose yaw rotation, wherein said machine learning engine operates locally on the mobile computing device without transmitting image data to an external server; and\n"
        "   (g) upon successful verification of said active facial liveness challenge, releasing said transaction dispatch to execute said payment transaction.\n\n"
        "2. The method of claim 1, wherein said predefined threshold value $T$ is â‚¹500.00.\n\n"
        "3. The method of claim 1, wherein evaluating said active facial liveness challenge comprises:\n"
        "   detecting that an eye openness probability falls below an eye-closed threshold of 0.25 after exceeding an eye-open threshold of 0.70; and\n"
        "   detecting that a head Euler yaw angle exceeds a magnitude of 20 degrees in a dynamically selected direction.\n\n"
        "4. The method of claim 1, further comprising aborting the payment transaction and locking retry attempts if said facial liveness challenge is not completed within a 15-second time window or exceeds 3 failed attempts.\n\n"
        "5. A mobile computing device configured to execute the method of claims 1 to 4."
    )

    add_h1("8. INSTITUTIONAL NEXT STEPS REQUIRED FOR FORMAL PATENT FILING")
    add_p(
        "To advance this invention disclosure toward a formally filed patent application with the Indian Patent Office (IPO), the following institutional "
        "and legal steps must be completed:\n"
        "â€¢ Step 1: Submission of this IDF to the Sharda University Intellectual Property Rights (IPR) Cell for novelty screening and prior art clearance.\n"
        "â€¢ Step 2: Formal review and recommendation by the Institutional Patent Evaluation Committee and Dean of Research, Sharda University.\n"
        "â€¢ Step 3: Engagement of a registered Patent Agent / Attorney to draft formal provisional or complete patent specifications.\n"
        "â€¢ Step 4: Execution of statutory filing forms: Form 1 (Application for Grant of Patent), Form 2 (Complete/Provisional Specification), Form 3 (Statement & Undertaking), Form 5 (Declaration as to Inventorship), and Form 26 (Power of Attorney).\n"
        "â€¢ Step 5: Official electronic filing via the Controller General of Patents, Designs and Trade Marks (CGPDTM) portal (ipindia.gov.in) to secure an official Indian Patent Application Number and Filing Date."
    )

    # Inventor Signatures Table
    add_h1("9. INVENTOR DECLARATION AND SIGNATURE BLOCKS")
    sig_table = doc.add_table(rows=4, cols=4)
    sig_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    s_col_w = [Inches(1.8), Inches(1.8), Inches(1.8), Inches(1.6)]
    
    s_headers = ["Inventor Name", "System ID / Roll No.", "Role / Affiliation", "Signature & Date"]
    s_hdr_row = sig_table.rows[0]
    for i, t in enumerate(s_headers):
        cell = s_hdr_row.cells[i]
        cell.width = s_col_w[i]
        set_cell_background(cell, '1F4E79')
        set_cell_margins(cell, top=80, bottom=80, left=80, right=80)
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(t)
        r.font.name = 'Arial'
        r.font.size = Pt(8.5)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    sig_data = [
        ("Aditya Veena Maharaj", "ID: 2024424251\nRoll: 2401010053", "Lead Student Inventor\nDept. of CSE, Sharda Univ.", "_____________________\nDate: ____/____/2026"),
        ("Gaurav Mudgal", "ID: 2024278918\nRoll: 2401010247", "Co-Student Inventor\nDept. of CSE, Sharda Univ.", "_____________________\nDate: ____/____/2026"),
        ("Dr. Gaurav Raj", "Emp ID: ____________", "Faculty Guide & Supervisor\nAssociate Professor, CSE", "_____________________\nDate: ____/____/2026")
    ]

    for r_idx, s_row in enumerate(sig_data):
        row = sig_table.rows[r_idx + 1]
        for c_idx, val in enumerate(s_row):
            cell = row.cells[c_idx]
            cell.width = s_col_w[c_idx]
            set_cell_margins(cell, top=80, bottom=80, left=80, right=80)
            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if c_idx == 3 else WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.line_spacing = 1.1
            r = p.add_run(val)
            r.font.name = 'Arial'
            r.font.size = Pt(8.5)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    doc.save(output_path)
    print(f"Patent IDF saved to: {output_path}")

if __name__ == '__main__':
    out_file = r'c:\Users\adity\Downloads\FacePay_Application\FacePay_PBL3_Submission\02_Patent_Invention_Disclosure.docx'
    build_patent_idf(out_file)

