import os
import docx
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

def prepare_rubric_3(src_path, dest_path):
    doc = docx.Document(src_path)
    
    # Update Paragraphs with verified data
    for p in doc.paragraphs:
        txt = p.text
        if 'Session:-' in txt:
            p.text = "Session: 2026-2027 (5th Semester)\t\t\t\tDate of Evaluation: ____ / ____ / 2026"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(10)
                r.font.bold = True
        elif 'Project Title Name:-' in txt:
            p.text = "Project Title Name: FacePay â€” Mandatory On-Device Facial Verification for Secure High-Value UPI Transactions"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(10)
                r.font.bold = True
                r.font.color.rgb = RGBColor(0x1F, 0x4E, 0x79)
        elif 'Software/Methodology/Tool used:-' in txt:
            p.text = "Software/Methodology/Tool used: Flutter (Dart), Google ML Kit Face Detection, Camera API, SharedPreferences, Razorpay Test Sandbox"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(10)
                r.font.bold = True
        elif 'Faculty Name: -' in txt:
            p.text = "Faculty Name: Dr. Gaurav Raj, Associate Professor, Department of Computer Science & Engineering"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(10)
                r.font.bold = True
        elif 'Internal Faculty Signature:' in txt:
            p.text = "Internal Faculty Signature: _________________________________________    Date: ____ / ____ / 2026"
            for r in p.runs:
                r.font.name = 'Times New Roman'
                r.font.size = Pt(10)
                r.font.bold = True

    # Update Table Header with verified Student Names and System IDs
    table = doc.tables[0]
    
    # Row 0: Student Names
    table.rows[0].cells[3].text = "Aditya Veena Maharaj"
    table.rows[0].cells[4].text = "Gaurav Mudgal"
    table.rows[0].cells[5].text = "N/A"
    table.rows[0].cells[6].text = "N/A"
    
    # Row 1-3 also repeat or merge headers in some views; ensure they look clean
    for r_idx in [1, 2, 3]:
        table.rows[r_idx].cells[3].text = "Aditya Veena Maharaj"
        table.rows[r_idx].cells[4].text = "Gaurav Mudgal"
        table.rows[r_idx].cells[5].text = "â€”"
        table.rows[r_idx].cells[6].text = "â€”"

    # Row 4, 5, 6: System IDs and Roll Numbers
    for r_idx in [4, 5, 6]:
        table.rows[r_idx].cells[3].text = "ID: 2024424251\nRoll: 2401010053"
        table.rows[r_idx].cells[4].text = "ID: 2024278918\nRoll: 2401010247"
        table.rows[r_idx].cells[5].text = "â€”"
        table.rows[r_idx].cells[6].text = "â€”"

    # Format cells nicely
    for row in table.rows:
        for cell in row.cells:
            for p in cell.paragraphs:
                p.paragraph_format.line_spacing = 1.05
                for r in p.runs:
                    r.font.name = 'Times New Roman'
                    r.font.size = Pt(8.5)

    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    doc.save(dest_path)
    print(f"Updated Rubric 3 saved to: {dest_path}")

if __name__ == '__main__':
    src = r'c:\Users\adity\Downloads\PBL-3_5th-Sem_Rubric-3_Evaluation-3.docx'
    dest = r'c:\Users\adity\Downloads\FacePay_Application\FacePay_PBL3_Submission\04_Rubric_3_For_Signature.docx'
    prepare_rubric_3(src, dest)

