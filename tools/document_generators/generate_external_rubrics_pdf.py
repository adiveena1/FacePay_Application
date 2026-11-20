import os
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, KeepTogether
)

def generate_pdf(output_path):
    # Setup document with 0.45 in margins so everything fits on 1 page cleanly
    margin = 32
    doc = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=margin,
        rightMargin=margin,
        topMargin=margin,
        bottomMargin=margin
    )

    story = []
    styles = getSampleStyleSheet()

    # Base styles
    title_style = ParagraphStyle(
        'HeaderTitle',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=12,
        leading=15,
        alignment=1, # Center
        textColor=colors.black
    )

    sub_title_style = ParagraphStyle(
        'HeaderSubTitle',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=11,
        leading=14,
        alignment=1,
        textColor=colors.black
    )

    meta_label = ParagraphStyle(
        'MetaLabel',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=9,
        leading=12,
        textColor=colors.black
    )

    meta_val = ParagraphStyle(
        'MetaVal',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=9,
        leading=12,
        textColor=colors.black
    )

    tbl_header = ParagraphStyle(
        'TblHeader',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=8,
        leading=10,
        alignment=1,
        textColor=colors.black
    )

    tbl_cell = ParagraphStyle(
        'TblCell',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=8,
        leading=10,
        textColor=colors.black
    )

    tbl_cell_bold = ParagraphStyle(
        'TblCellBold',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.black
    )

    tbl_center = ParagraphStyle(
        'TblCenter',
        parent=styles['Normal'],
        fontName='Times-Roman',
        fontSize=8,
        leading=10,
        alignment=1,
        textColor=colors.black
    )

    tbl_center_bold = ParagraphStyle(
        'TblCenterBold',
        parent=styles['Normal'],
        fontName='Times-Bold',
        fontSize=8,
        leading=10,
        alignment=1,
        textColor=colors.black
    )

    # 1. Header (Logo + Title)
    logo_path = os.path.join(os.path.dirname(__file__), "sharda_logo.png")
    header_data = []
    if os.path.exists(logo_path):
        img = Image(logo_path, width=75, height=58)
        header_text = [
            Paragraph("<b>Sharda University, Greater Noida, Uttar Pradesh 201310</b>", title_style),
            Paragraph("<b>External Assessment Sheet for B.Tech Project Based Learning 5<sup>th</sup> Semester (CSP 391)</b>", sub_title_style),
        ]
        header_table = Table([[img, header_text]], colWidths=[85, 460])
        header_table.setStyle(TableStyle([
            ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
            ('ALIGN', (0,0), (0,0), 'CENTER'),
        ]))
        story.append(header_table)
    else:
        story.append(Paragraph("<b>Sharda University, Greater Noida, Uttar Pradesh 201310</b>", title_style))
        story.append(Paragraph("<b>External Assessment Sheet for B.Tech Project Based Learning 5<sup>th</sup> Semester (CSP 391)</b>", sub_title_style))

    story.append(Spacer(1, 6))

    # 2. Metadata Information Block
    meta_data = [
        [
            Paragraph("<b>Session:</b> 2026-2027 (Semester 5)", meta_val),
            Paragraph("<b>Date of Evaluation:</b> November 2026", meta_val)
        ],
        [
            Paragraph("<b>Project Title Name:</b> FacePay — Mandatory On-Device Facial Verification for Secure High-Value UPI Transactions", meta_val),
            ""
        ],
        [
            Paragraph("<b>Software/Methodology/Tool used:</b> Flutter, Dart, Google ML Kit (Vision), CameraX, Android SDK 36, Material 3, SharedPreferences", meta_val),
            ""
        ],
        [
            Paragraph("<b>Faculty Name:</b> Dr. Gaurav Raj (Associate Professor, Department of CSE)", meta_val),
            ""
        ]
    ]

    meta_table = Table(meta_data, colWidths=[380, 165])
    meta_table.setStyle(TableStyle([
        ('SPAN', (0, 1), (1, 1)),
        ('SPAN', (0, 2), (1, 2)),
        ('SPAN', (0, 3), (1, 3)),
        ('TOPPADDING', (0,0), (-1,-1), 1),
        ('BOTTOMPADDING', (0,0), (-1,-1), 1),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(meta_table)
    story.append(Spacer(1, 6))

    # 3. Rubric Matrix Table
    # Columns:
    # 0: Components (85 pt)
    # 1: Sub-Components (175 pt)
    # 2: Max Marks (38 pt)
    # 3: Aditya Veena Maharaj (88 pt)
    # 4: Gaurav Mudgal (88 pt)
    # 5: Student 3 (38 pt)
    # 6: Student 4 (38 pt)
    # Total width = 85 + 175 + 38 + 88 + 88 + 38 + 38 = 550 pt (matches printable letter width 612 - 64 = 548)
    col_w = [85, 175, 38, 88, 88, 38, 38]

    rubric_cells = [
        # Row 0: Header
        [
            Paragraph("<b>Components</b>", tbl_header),
            Paragraph("<b>RUBRICS FOR PBL</b><br/><font size=6.5>EXCELLENT – 4 | GOOD – 3 | AVERAGE – 2 | ACCEPTABLE – 1 | POOR – 0</font>", tbl_header),
            Paragraph("<b>Max<br/>Marks</b>", tbl_header),
            Paragraph("<b>Aditya Veena Maharaj</b>", tbl_header),
            Paragraph("<b>Gaurav Mudgal</b>", tbl_header),
            Paragraph("<b>Name of<br/>Student 3</b>", tbl_header),
            Paragraph("<b>Name of<br/>Student 4</b>", tbl_header),
        ],
        # Row 1: System IDs
        [
            "",
            Paragraph("<b>Sub-Components</b>", tbl_header),
            "",
            Paragraph("<b>System ID:</b><br/>2024424251", tbl_center_bold),
            Paragraph("<b>System ID:</b><br/>2024278918", tbl_center_bold),
            Paragraph("System ID:<br/>—", tbl_center),
            Paragraph("System ID:<br/>—", tbl_center),
        ],
        # Row 2: Marks Obtained row
        [
            "",
            "",
            "",
            Paragraph("<i>Marks Obtained</i>", tbl_center),
            Paragraph("<i>Marks Obtained</i>", tbl_center),
            Paragraph("<i>Marks</i>", tbl_center),
            Paragraph("<i>Marks</i>", tbl_center),
        ],
        # Rows 3-12: Data rows
        # 3
        [
            Paragraph("<b>Problem<br/>Analysis</b><br/>(8 marks)", tbl_center_bold),
            Paragraph("Identification of Problem Domain and Detailed Analysis", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 4
        [
            "",
            Paragraph("Study of the Existing Systems and Feasibility of Project Proposal", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 5
        [
            Paragraph("<b>Project<br/>Design</b><br/>(8 marks)", tbl_center_bold),
            Paragraph("Objectives and information Methodology of the Proposed Work", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 6
        [
            "",
            Paragraph("Relevancy of Algorithms / Techniques", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 7
        [
            Paragraph("<b>Project<br/>Implementation</b><br/>(8 marks)", tbl_center_bold),
            Paragraph("Synchronization of Design & Implementation", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 8
        [
            "",
            Paragraph("Project Demonstration (Modules properly Implemented with correct results)", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 9
        [
            Paragraph("<b>Project<br/>Report</b><br/>(8 marks)", tbl_center_bold),
            Paragraph("Well-organized Project Report", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 10
        [
            "",
            Paragraph("Project report according to the specified Format", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 11
        [
            Paragraph("<b>Communication</b><br/>(8 marks)", tbl_center_bold),
            Paragraph("Presentation of project work is clear and well-organized", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # 12
        [
            "",
            Paragraph("Each member contributed in a valuable way to the project", tbl_cell),
            Paragraph("4", tbl_center), "", "", "—", "—"
        ],
        # Row 13: Total
        [
            Paragraph("<b>Total Marks</b>", tbl_center_bold),
            Paragraph("<b>Total Score out of 40 (Evaluator Assessment)</b>", tbl_cell_bold),
            Paragraph("<b>40</b>", tbl_center_bold),
            "", "", "—", "—"
        ],
        # Row 14: Comment box
        [
            Paragraph("<b>Evaluator’s Overall Comment:</b>", tbl_cell_bold),
            "", "", "", "", "", ""
        ]
    ]

    t_rubric = Table(rubric_cells, colWidths=col_w)
    t_style = [
        # Grid
        ('GRID', (0,0), (-1,-1), 0.5, colors.black),
        ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
        ('LEFTPADDING', (0,0), (-1,-1), 3),
        ('RIGHTPADDING', (0,0), (-1,-1), 3),

        # Spans for Headers
        ('SPAN', (0, 0), (0, 2)), # Components
        ('SPAN', (2, 0), (2, 2)), # Max Marks
        
        # Spans for Components
        ('SPAN', (0, 3), (0, 4)), # Problem Analysis
        ('SPAN', (0, 5), (0, 6)), # Project Design
        ('SPAN', (0, 7), (0, 8)), # Project Implementation
        ('SPAN', (0, 9), (0, 10)), # Project Report
        ('SPAN', (0, 11), (0, 12)), # Communication

        # Span for Comment
        ('SPAN', (0, 14), (6, 14)),

        # Backgrounds
        ('BACKGROUND', (0, 0), (-1, 2), colors.HexColor('#F4F6F8')),
        ('BACKGROUND', (0, 13), (-1, 13), colors.HexColor('#EAECEF')),
        ('BOTTOMPADDING', (0, 14), (6, 14), 22), # Give height to comment box
    ]
    t_rubric.setStyle(TableStyle(t_style))
    story.append(t_rubric)
    story.append(Spacer(1, 12))

    # 4. Signatures Block
    sig_data = [
        [
            Paragraph("<b>Evaluator’s Name:</b> ___________________________", meta_val),
            Paragraph("<b>Evaluator’s Signature:</b> ___________________________", meta_val)
        ],
        [
            Paragraph("<b>Internal Examiner Name:</b> Dr. Gaurav Raj", meta_val),
            Paragraph("<b>Internal Examiner Signature:</b> ___________________________", meta_val)
        ]
    ]
    sig_table = Table(sig_data, colWidths=[275, 275])
    sig_table.setStyle(TableStyle([
        ('TOPPADDING', (0,0), (-1,-1), 4),
        ('BOTTOMPADDING', (0,0), (-1,-1), 4),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
        ('RIGHTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(sig_table)

    doc.build(story)
    print(f"External Assessment Sheet PDF generated successfully at: {output_path}")

if __name__ == '__main__':
    out_pdf = r"c:\Users\adity\Downloads\FacePay_Application\FacePay_PBL3_Submission\External_Rubrics_CSP391_For_Evaluation.pdf"
    generate_pdf(out_pdf)
