import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_shading(cell, color_hex):
    shading_xml = f'<w:shd {nsdecls("w")} w:val="clear" w:color="auto" w:fill="{color_hex}"/>'
    cell._tc.get_or_add_tcPr().append(parse_xml(shading_xml))

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = OxmlElement('w:tcMar')
    for m, val in [('w:top', top), ('w:bottom', bottom), ('w:left', left), ('w:right', right)]:
        node = OxmlElement(m)
        node.set(qn('w:w'), str(val))
        node.set(qn('w:type'), 'dxa')
        tcMar.append(node)
    tcPr.append(tcMar)

def create_external_rubrics_doc(output_path):
    doc = Document()

    # 1-inch margins
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(0.6)
        section.bottom_margin = Inches(0.6)
        section.left_margin = Inches(0.65)
        section.right_margin = Inches(0.65)

    # Header Table: Logo + Text
    header_table = doc.add_table(rows=1, cols=2)
    header_table.alignment = WD_TABLE_ALIGNMENT.CENTER
    header_table.autofit = False
    header_table.columns[0].width = Inches(1.3)
    header_table.columns[1].width = Inches(5.9)

    cell_logo = header_table.cell(0, 0)
    cell_text = header_table.cell(0, 1)

    logo_path = os.path.join(os.path.dirname(__file__), "sharda_logo.png")
    if os.path.exists(logo_path):
        p_logo = cell_logo.paragraphs[0]
        p_logo.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run_logo = p_logo.add_run()
        run_logo.add_picture(logo_path, width=Inches(1.2))

    p_title = cell_text.paragraphs[0]
    p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_title.paragraph_format.space_before = Pt(0)
    p_title.paragraph_format.space_after = Pt(2)
    r1 = p_title.add_run("Sharda University, Greater Noida, Uttar Pradesh 201310\n")
    r1.font.name = "Times New Roman"
    r1.font.size = Pt(13)
    r1.font.bold = True

    r2 = p_title.add_run("External Assessment Sheet for B.Tech Project Based Learning 5th Semester (CSP 391)")
    r2.font.name = "Times New Roman"
    r2.font.size = Pt(12)
    r2.font.bold = True

    # Metadata Paragraphs
    p_meta1 = doc.add_paragraph()
    p_meta1.paragraph_format.space_before = Pt(8)
    p_meta1.paragraph_format.space_after = Pt(3)
    r_sess = p_meta1.add_run("Session: ")
    r_sess.bold = True
    p_meta1.add_run("2026-2027 (5th Semester)                                    ")
    r_date = p_meta1.add_run("Date of Evaluation: ")
    r_date.bold = True
    p_meta1.add_run("November 2026")

    p_proj = doc.add_paragraph()
    p_proj.paragraph_format.space_before = Pt(2)
    p_proj.paragraph_format.space_after = Pt(2)
    r_p1 = p_proj.add_run("Project Title Name: ")
    r_p1.bold = True
    p_proj.add_run("FacePay — Mandatory On-Device Facial Verification for Secure High-Value UPI Transactions")

    p_tool = doc.add_paragraph()
    p_tool.paragraph_format.space_before = Pt(2)
    p_tool.paragraph_format.space_after = Pt(2)
    r_t1 = p_tool.add_run("Software/Methodology/Tool used: ")
    r_t1.bold = True
    p_tool.add_run("Flutter, Dart, Google ML Kit Face Detection, CameraX, Android SDK 36, Material 3, SharedPreferences")

    p_fac = doc.add_paragraph()
    p_fac.paragraph_format.space_before = Pt(2)
    p_fac.paragraph_format.space_after = Pt(6)
    r_f1 = p_fac.add_run("Faculty Name: ")
    r_f1.bold = True
    p_fac.add_run("Dr. Gaurav Raj, Associate Professor, Department of CSE")

    # Assessment Rubrics Table
    # Columns:
    # 0: Components
    # 1: Sub-Components
    # 2: Max Marks
    # 3: Student 1 (Aditya Veena Maharaj)
    # 4: Student 2 (Gaurav Mudgal)
    # 5: Student 3
    # 6: Student 4

    rubric_rows = [
        # (Component, Sub-Component, Max)
        ("Problem Analysis\n(8 marks)", "Identification of Problem Domain and Detailed Analysis", "4"),
        ("Problem Analysis\n(8 marks)", "Study of the Existing Systems and Feasibility of Project Proposal", "4"),
        ("Project Design\n(8 marks)", "Objectives and information Methodology of the Proposed Work", "4"),
        ("Project Design\n(8 marks)", "Relevancy of Algorithms / Techniques", "4"),
        ("Project Implementation\n(8 marks)", "Synchronization of Design & Implementation", "4"),
        ("Project Implementation\n(8 marks)", "Project Demonstration (Modules properly Implemented with correct results)", "4"),
        ("Project Report\n(8 marks)", "Well-organized Project Report", "4"),
        ("Project Report\n(8 marks)", "Project report according to the specified Format", "4"),
        ("Communication\n(8 marks)", "Presentation of project work is clear and well-organized", "4"),
        ("Communication\n(8 marks)", "Each member contributed in a valuable way to the project", "4"),
    ]

    # Total rows: Header (4 rows) + 10 data rows + 1 total row = 15 rows
    table = doc.add_table(rows=15, cols=7)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.autofit = False

    col_widths = [Inches(1.2), Inches(2.2), Inches(0.55), Inches(1.15), Inches(1.15), Inches(0.6), Inches(0.6)]
    for row in table.rows:
        for idx, width in enumerate(col_widths):
            row.cells[idx].width = width

    # Row 0: Headers
    # cell(0,0): Components
    # cell(0,1): RUBRICS FOR PBL
    # cell(0,2): Max Marks
    # cell(0,3): Name of Student 1
    # cell(0,4): Name of Student 2
    # cell(0,5): Name of Student 3
    # cell(0,6): Name of Student 4

    r0 = table.rows[0]
    r0.cells[0].text = "Components"
    r0.cells[1].text = "RUBRICS FOR PBL\nEXCELLENT – 4 MARKS | GOOD – 3 MARKS\nAVERAGE – 2 MARKS | ACCEPTABLE – 1 MARKS | POOR – 0"
    r0.cells[2].text = "Max\nMarks"
    r0.cells[3].text = "Aditya Veena Maharaj"
    r0.cells[4].text = "Gaurav Mudgal"
    r0.cells[5].text = "Name of Student 3"
    r0.cells[6].text = "Name of Student 4"

    # Row 1: System IDs
    r1 = table.rows[1]
    r1.cells[0].text = ""
    r1.cells[1].text = "Sub-Components"
    r1.cells[2].text = ""
    r1.cells[3].text = "System ID:\n2024424251"
    r1.cells[4].text = "System ID:\n2024278918"
    r1.cells[5].text = "System ID:\n—"
    r1.cells[6].text = "System ID:\n—"

    # Row 2: Marks Obtained header
    r2 = table.rows[2]
    r2.cells[0].text = ""
    r2.cells[1].text = ""
    r2.cells[2].text = ""
    r2.cells[3].text = "Marks Obtained"
    r2.cells[4].text = "Marks Obtained"
    r2.cells[5].text = "Marks Obtained"
    r2.cells[6].text = "Marks Obtained"

    # Fill data rows (3 to 12)
    for idx, (comp, subcomp, max_m) in enumerate(rubric_rows):
        row_idx = 3 + idx
        r = table.rows[row_idx]
        r.cells[0].text = comp if idx % 2 == 0 else "" # component name on first of pair
        r.cells[1].text = subcomp
        r.cells[2].text = max_m
        r.cells[3].text = ""  # Clean for examiner
        r.cells[4].text = ""
        r.cells[5].text = "—"
        r.cells[6].text = "—"

    # Total Marks row (row 13)
    r_tot = table.rows[13]
    r_tot.cells[0].text = "Total Marks"
    r_tot.cells[1].text = "Out of 40 (Evaluator Assessment)"
    r_tot.cells[2].text = "40"
    r_tot.cells[3].text = ""
    r_tot.cells[4].text = ""
    r_tot.cells[5].text = "—"
    r_tot.cells[6].text = "—"

    # Row 14: Evaluator's Overall Comment
    r_comm = table.rows[14]
    r_comm.cells[0].text = "Evaluator’s Overall Comment:"
    r_comm.cells[1].text = ""
    r_comm.cells[2].text = ""
    r_comm.cells[3].text = ""
    r_comm.cells[4].text = ""
    r_comm.cells[5].text = ""
    r_comm.cells[6].text = ""

    # Merge cell 14 across 1 to 6
    for c in range(1, 7):
        r_comm.cells[0].merge(r_comm.cells[c])

    # Merge component cells in pairs: (3,4), (5,6), (7,8), (9,10), (11,12)
    for base in [3, 5, 7, 9, 11]:
        table.rows[base].cells[0].merge(table.rows[base + 1].cells[0])

    # Merge headers
    table.rows[0].cells[0].merge(table.rows[2].cells[0]) # Components
    table.rows[0].cells[2].merge(table.rows[2].cells[2]) # Max Marks

    # Style table
    for row_i, row in enumerate(table.rows):
        for cell in row.cells:
            set_cell_margins(cell, top=60, bottom=60, left=90, right=90)
            cell.vertical_alignment = WD_ALIGN_VERTICAL.CENTER
            for p in cell.paragraphs:
                p.paragraph_format.space_before = Pt(1)
                p.paragraph_format.space_after = Pt(1)
                p.paragraph_format.line_spacing = 1.0
                for run in p.runs:
                    run.font.name = "Times New Roman"
                    run.font.size = Pt(8.5)
                    if row_i in [0, 1, 2, 13]:
                        run.font.bold = True

    # Color headers
    for cell in table.rows[0].cells:
        set_cell_shading(cell, "F2F4F7")
    for cell in table.rows[1].cells:
        set_cell_shading(cell, "F2F4F7")
    for cell in table.rows[2].cells:
        set_cell_shading(cell, "EAECEF")
    for cell in table.rows[13].cells:
        set_cell_shading(cell, "EAECEF")

    # Add XML borders to all table cells
    tblPr = table._tbl.tblPr
    tblBorders = parse_xml(
        f'<w:tblBorders {nsdecls("w")}>'
        f'<w:top w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        f'<w:left w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        f'<w:bottom w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        f'<w:right w:val="single" w:sz="6" w:space="0" w:color="000000"/>'
        f'<w:insideH w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        f'<w:insideV w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>'
        f'</w:tblBorders>'
    )
    tblPr.append(tblBorders)

    # Signature Footer Paragraph
    p_sig = doc.add_paragraph()
    p_sig.paragraph_format.space_before = Pt(16)
    p_sig.paragraph_format.space_after = Pt(4)
    r_ev1 = p_sig.add_run("Evaluator’s Name: ")
    r_ev1.bold = True
    p_sig.add_run("___________________________             ")
    r_ev2 = p_sig.add_run("Evaluator’s Signature: ")
    r_ev2.bold = True
    p_sig.add_run("___________________________")

    p_int = doc.add_paragraph()
    p_int.paragraph_format.space_before = Pt(6)
    p_int.paragraph_format.space_after = Pt(2)
    r_in1 = p_int.add_run("Internal Examiner Name: ")
    r_in1.bold = True
    p_int.add_run("Dr. Gaurav Raj                     ")
    r_in2 = p_int.add_run("Internal Examiner Signature: ")
    r_in2.bold = True
    p_int.add_run("___________________________")

    doc.save(output_path)
    print(f"External Assessment Sheet saved to: {output_path}")

if __name__ == "__main__":
    out = r"c:\Users\adity\Downloads\FacePay_Application\FacePay_PBL3_Submission\External_Rubrics_CSP391_For_Evaluation.docx"
    create_external_rubrics_doc(out)
