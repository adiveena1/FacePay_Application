import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

def set_cell_background(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=120, right=120):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
        node = OxmlElement(f'w:{m}')
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def add_callout(doc, text, title=None, border_color='1F4E79', bg_color='F2F4F7'):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = tbl.cell(0, 0)
    set_cell_background(cell, bg_color)
    set_cell_margins(cell, top=120, bottom=120, left=160, right=160)
    
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
        r_t.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
    r = p.add_run(text)
    r.font.name = 'Arial'
    r.font.size = Pt(9.5)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

def build_submission_checklist(output_path):
    doc = docx.Document()
    
    for s in doc.sections:
        s.top_margin = Inches(0.8)
        s.bottom_margin = Inches(0.8)
        s.left_margin = Inches(0.8)
        s.right_margin = Inches(0.8)
        
        footer = s.footer
        fp = footer.paragraphs[0]
        fp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        fr = fp.add_run("PBL-3 Deliverables Checklist & Audit Matrix | Sharda University")
        fr.font.name = 'Arial'
        fr.font.size = Pt(8.5)
        fr.font.color.rgb = RGBColor(0x7F, 0x7F, 0x7F)

    # Header
    p_hdr = doc.add_paragraph()
    p_hdr.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_hdr = p_hdr.add_run("SHARDA UNIVERSITY â€” SCHOOL OF COMPUTING SCIENCE & ENGINEERING\n")
    r_hdr.font.name = 'Arial'
    r_hdr.font.size = Pt(12)
    r_hdr.font.bold = True
    r_hdr.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
    
    r_sub = p_hdr.add_run("PBL-3 (CSP-391) SUBMISSION DELIVERABLES CHECKLIST & STATUS MATRIX\n"
                          "Project: FacePay â€” Mandatory On-Device Facial Verification for Secure High-Value UPI Transactions\n"
                          "Team: Aditya Veena Maharaj (2024424251) & Gaurav Mudgal (2024278918) | Section: CSJ (G2)")
    r_sub.font.name = 'Arial'
    r_sub.font.size = Pt(10)
    r_sub.font.bold = True
    p_hdr.paragraph_format.space_after = Pt(12)

    add_callout(
        doc,
        "SUBMISSION READINESS SUMMARY:\n"
        "All required capstone deliverables for FacePay have been systematically generated and placed in the "
        "`FacePay_PBL3_Submission/` directory. Each item has been audited against authentic project source code, "
        "verified student and faculty details, and Sharda University evaluation criteria. The primary intended PBL Outcome "
        "for the Google Form submission is Option 1: 'Research Paper in IEEE format' (`01_IEEE_Research_Paper.pdf`).",
        title="EXECUTIVE SUBMISSION DIRECTIVE"
    )

    def add_h1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        r = p.add_run(text)
        r.font.name = 'Arial'
        r.font.size = Pt(10.5)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
        return p

    add_h1("1. COMPLETE DELIVERABLES STATUS MATRIX")

    # Checklist Table
    tbl = doc.add_table(rows=9, cols=5)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    c_w = [Inches(0.6), Inches(1.8), Inches(1.6), Inches(1.5), Inches(1.4)]
    
    headers = ["Item", "Document Title & Scope", "File Names in Submission Dir", "Verification & Audit Status", "Student Action Required"]
    for i, h in enumerate(headers):
        c = tbl.rows[0].cells[i]
        c.width = c_w[i]
        set_cell_background(c, '1F4E79')
        set_cell_margins(c, top=80, bottom=80, left=80, right=80)
        p = c.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h)
        r.font.name = 'Arial'
        r.font.size = Pt(8.5)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    items_data = [
        ("01", "IEEE Research Paper\n(PBL Outcome 1)", "01_IEEE_Research_Paper.docx\n01_IEEE_Research_Paper.pdf", "100% COMPLETE\nAcademic IEEE format, verified references, 6 pages", "Upload PDF to Google Form under 'PBL Outcome Evidence'"),
        ("02", "Patent Invention Disclosure\n(PBL Outcome 2 - Draft)", "02_Patent_Invention_Disclosure.docx\n02_Patent_Invention_Disclosure.pdf", "100% COMPLETE\nDraft IDF, statutory disclaimers, 5 draft claims", "Submit to Sharda IPR Cell for official patent evaluation"),
        ("03", "Hackathon Evidence &\nRequest Dossier", "03_Authentic_Hackathon_Certificate_Aditya.pdf\n03_Hackathon_Certificate_Request.docx", "VERIFIED EVIDENCE (Aditya)\nREQUEST READY (Gaurav)", "Email request letter to Anand Gaur; present PDF to panel"),
        ("04", "Rubric 3 Evaluation Form\n(Rubric #R3: Evaluation - 3)", "04_Rubric_3_For_Signature.docx\n04_Rubric_3_For_Signature.pdf", "PRE-FILLED & READY\nPreserves official format; leaves marks/signs blank", "Print PDF; present to Dr. Gaurav Raj during viva for evaluation"),
        ("05", "Final Project Report\n(Comprehensive 27-Page)", "05_Final_Project_Report.docx\n05_Final_Project_Report.pdf", "100% COMPLETE\n32 sections, UML/DFD diagrams, real test results", "Print spiral-bound copies; submit digital copy to department"),
        ("06", "Internal Originality &\nCitation Review Report", "06_Originality_Review_Report.pdf\n06_Originality_Review_Report.docx", "100% COMPLETE\nSource provenance audit, no fake Turnitin score", "Submit Report DOCX to Dr. Gaurav Raj for official Turnitin run"),
        ("07", "Deliverables Checklist\n& Submission Matrix", "07_Submission_Checklist.docx\n07_Submission_Checklist.pdf", "100% COMPLETE\nDetailed audit mapping across all rubrics", "Keep in project binder as front-matter audit sheet"),
        ("08", "Instructions & Readme", "README_Submission_Instructions.txt", "100% COMPLETE\nStep-by-step instructions for evaluation day", "Review before attending project viva-voce")
    ]

    for r_idx, r_data in enumerate(items_data):
        row = tbl.rows[r_idx + 1]
        bg = 'FFFFFF' if r_idx % 2 == 0 else 'F8FAFC'
        for c_idx, val in enumerate(r_data):
            cell = row.cells[c_idx]
            cell.width = c_w[c_idx]
            set_cell_background(cell, bg)
            set_cell_margins(cell, top=60, bottom=60, left=70, right=70)
            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if c_idx in [0] else WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.line_spacing = 1.05
            r = p.add_run(val)
            r.font.name = 'Arial'
            r.font.size = Pt(8.0)
            if "COMPLETE" in val or "VERIFIED" in val:
                if c_idx == 3:
                    r.font.bold = True
                    r.font.color.rgb = RGBColor(0x00, 0x80, 0x00)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    add_h1("2. MAPPING TO RUBRIC 3 EVALUATION CRITERIA (35 MARKS)")

    # Rubric Mapping Table
    tbl_rub = doc.add_table(rows=8, cols=4)
    tbl_rub.alignment = WD_TABLE_ALIGNMENT.CENTER
    r_w = [Inches(2.0), Inches(0.8), Inches(2.2), Inches(1.9)]
    
    r_headers = ["Rubric Sub-Component", "Max Marks", "Satisfying Artifact & Section", "Evidence Highlight"]
    for i, h in enumerate(r_headers):
        c = tbl_rub.rows[0].cells[i]
        c.width = r_w[i]
        set_cell_background(c, '1F4E79')
        set_cell_margins(c, top=80, bottom=80, left=80, right=80)
        p = c.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h)
        r.font.name = 'Arial'
        r.font.size = Pt(8.5)
        r.font.bold = True
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)

    rub_map = [
        ("1. Verification of Project (PO6)", "5", "Report Chapter 7 & Section VII (Research Paper)", "Automated Flutter test suite (8/8 unit & widget tests passed)"),
        ("2. Validity of Project (PO4)", "5", "Report Chapter 2, 3 & Section II, IV", "Lok Sabha UPI fraud data (â‚¹981 Cr), 5-paper comparative matrix"),
        ("3. Project Execution Demo (PO9, PO11)", "5", "Live Flutter APK / Video Demonstration", "Working QR scan, â‚¹500 bypass, > â‚¹500 face liveness challenge"),
        ("4. Quality of Final Project Report (PO3)", "5", "File 05_Final_Project_Report.pdf (27 pages)", "32 complete academic sections, UML & DFD diagrams, pseudocode"),
        ("5. Communication (Presentation) (PO10)", "5", "Implementation Review Presentation & Viva", "Clear technical defense of edge AI and privacy guarantees"),
        ("6. Project Report Submission (PO12)", "5", "Files 04, 05, 06 & Submission Directory", "Timely, professional submission with source attribution audit"),
        ("7. Research Paper Publication (PSO1-3)", "5", "File 01_IEEE_Research_Paper.pdf (6 pages)", "Camera-ready IEEE format manuscript targeting Scopus/IEEE venue")
    ]

    for r_idx, r_data in enumerate(rub_map):
        row = tbl_rub.rows[r_idx + 1]
        bg = 'FFFFFF' if r_idx % 2 == 0 else 'F8FAFC'
        for c_idx, val in enumerate(r_data):
            cell = row.cells[c_idx]
            cell.width = r_w[c_idx]
            set_cell_background(cell, bg)
            set_cell_margins(cell, top=60, bottom=60, left=70, right=70)
            p = cell.paragraphs[0]
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER if c_idx == 1 else WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.line_spacing = 1.05
            r = p.add_run(val)
            r.font.name = 'Arial'
            r.font.size = Pt(8.0)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)

    add_h1("3. GOOGLE FORM SUBMISSION GUIDANCE")
    p_gf = doc.add_paragraph()
    p_gf.paragraph_format.line_spacing = 1.15
    r_gf = p_gf.add_run(
        "â€¢ Field 'PBL Outcome Selection': Select 'Research Paper in IEEE format'.\n"
        "â€¢ Field 'Outcome File Upload': Upload `01_IEEE_Research_Paper.pdf`.\n"
        "â€¢ Field 'Project Report Upload': Upload `05_Final_Project_Report.pdf`.\n"
        "â€¢ Field 'Signed Rubric': Print `04_Rubric_3_For_Signature.pdf`, obtain Dr. Gaurav Raj's handwritten marks & signature during viva, then scan and upload.\n"
        "â€¢ Field 'Plagiarism Report': Submit `05_Final_Project_Report.docx` to Dr. Gaurav Raj or Central Library for the official Turnitin PDF."
    )
    r_gf.font.name = 'Arial'
    r_gf.font.size = Pt(9.0)

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    doc.save(output_path)
    print(f"Submission Checklist saved to: {output_path}")

if __name__ == '__main__':
    out_file = r'c:\Users\adity\Downloads\FacePay_Application\FacePay_PBL3_Submission\07_Submission_Checklist.docx'
    build_submission_checklist(out_file)

