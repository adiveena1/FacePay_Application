import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches

os.makedirs('report_diagrams', exist_ok=True)

def generate_use_case_diagram():
    fig, ax = plt.subplots(figsize=(8, 6), dpi=300)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Boundary box
    rect = patches.FancyBboxPatch((2.2, 0.5), 5.6, 7.0, boxstyle="round,pad=0.3", 
                                  edgecolor="#1F4E79", facecolor="#F8FAFC", linewidth=2)
    ax.add_patch(rect)
    ax.text(5.0, 7.2, "FacePay Mobile System Boundary", ha="center", va="center", 
            fontsize=12, fontweight="bold", color="#1F4E79", fontfamily="sans-serif")
    
    # Actors
    # User Actor (left)
    ax.plot([1.0], [4.5], 'o', markersize=14, color="#1F4E79")
    ax.plot([1.0, 1.0], [4.1, 3.2], color="#1F4E79", lw=2.5) # body
    ax.plot([0.5, 1.5], [3.8, 3.8], color="#1F4E79", lw=2.5) # arms
    ax.plot([1.0, 0.6], [3.2, 2.3], color="#1F4E79", lw=2.5) # left leg
    ax.plot([1.0, 1.4], [3.2, 2.3], color="#1F4E79", lw=2.5) # right leg
    ax.text(1.0, 1.9, "Payer / Student\n(User)", ha="center", va="top", fontsize=9, fontweight="bold")

    # Payment Gateway Actor (right)
    ax.plot([9.0], [4.5], 's', markersize=16, color="#2E7D32")
    ax.text(9.0, 3.8, "Payment Simulator /\nRazorpay Sandbox", ha="center", va="top", fontsize=9, fontweight="bold", color="#2E7D32")
    
    # Use cases (Ovals)
    use_cases = [
        (5.0, 6.2, "Scan Merchant QR Code"),
        (5.0, 5.0, "Enter & Validate Amount"),
        (5.0, 3.8, "Verify Face Liveness (> ₹500)\n«includes» Blink & Yaw Checks"),
        (5.0, 2.6, "Authorize & Execute Payment"),
        (5.0, 1.4, "View Local History & Badges")
    ]
    
    for x, y, label in use_cases:
        ellipse = patches.Ellipse((x, y), 3.8, 0.85, edgecolor="#1F4E79", facecolor="#FFFFFF", linewidth=1.5)
        ax.add_patch(ellipse)
        ax.text(x, y, label, ha="center", va="center", fontsize=8.5, fontweight="semibold", color="#1E293B")
        
        # Connect from User
        ax.plot([1.2, x - 1.8], [4.0, y], color="#64748B", linestyle="--", lw=1.2)
        
        # Connect to Gateway for payment
        if "Execute Payment" in label:
            ax.plot([x + 1.8, 8.5], [y, 4.3], color="#2E7D32", linestyle="-", lw=1.5)

    plt.tight_layout()
    plt.savefig('report_diagrams/use_case_diagram.png', bbox_inches='tight')
    plt.close()
    print("Use Case diagram generated.")

def generate_dfd_diagram():
    fig, ax = plt.subplots(figsize=(9, 5.5), dpi=300)
    ax.set_xlim(0, 11)
    ax.set_ylim(0, 7)
    ax.axis('off')
    
    # Level 1 DFD
    # External Entity: User
    rect_user = patches.Rectangle((0.5, 4.5), 1.8, 1.5, edgecolor="#1F4E79", facecolor="#E2E8F0", linewidth=1.5)
    ax.add_patch(rect_user)
    ax.text(1.4, 5.25, "Student /\nMobile User", ha="center", va="center", fontsize=9, fontweight="bold", color="#1F4E79")
    
    # Process 1.0: QR Scanner & Amount Parsing
    p1 = patches.Circle((4.2, 5.25), 0.9, edgecolor="#1F4E79", facecolor="#F0F9FF", linewidth=1.5)
    ax.add_patch(p1)
    ax.text(4.2, 5.25, "1.0\nQR Scan &\nThreshold\nEvaluation", ha="center", va="center", fontsize=7.5, fontweight="bold")
    
    # Process 2.0: ML Kit Liveness Verification
    p2 = patches.Circle((7.5, 5.25), 0.9, edgecolor="#C00000", facecolor="#FFF1F2", linewidth=1.5)
    ax.add_patch(p2)
    ax.text(7.5, 5.25, "2.0\nEdge AI\nLiveness\nVerification", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#991B1B")

    # Process 3.0: Payment Orchestration
    p3 = patches.Circle((5.8, 2.0), 0.9, edgecolor="#2E7D32", facecolor="#F0FDF4", linewidth=1.5)
    ax.add_patch(p3)
    ax.text(5.8, 2.0, "3.0\nPayment\nSimulation\nEngine", ha="center", va="center", fontsize=7.5, fontweight="bold", color="#166534")

    # Data Store: Local SharedPreferences
    ds_top = patches.Rectangle((8.5, 1.3), 2.2, 1.2, edgecolor="#334155", facecolor="#FFFFFF", linewidth=1.2)
    ax.add_patch(ds_top)
    ax.plot([8.5, 8.5], [1.3, 2.5], color="#334155", lw=1.5)
    ax.text(9.6, 1.9, "D1: Local Ledger &\nRewards Store", ha="center", va="center", fontsize=8, fontweight="bold")

    # Arrows
    # User to 1.0
    ax.annotate("QR Code &\nAmount", xy=(3.3, 5.25), xytext=(2.3, 5.25),
                arrowprops=dict(arrowstyle="->", color="#1F4E79", lw=1.5), fontsize=7.5, ha="center", va="bottom")
    
    # 1.0 to 2.0 (> 500)
    ax.annotate("Amount > ₹500\nTrigger Camera", xy=(6.6, 5.4), xytext=(5.1, 5.4),
                arrowprops=dict(arrowstyle="->", color="#C00000", lw=1.5), fontsize=7.5, ha="center", va="bottom")

    # 1.0 to 3.0 (<= 500)
    ax.annotate("Amount <= ₹500\nBypass Face Auth", xy=(5.0, 2.6), xytext=(3.8, 4.4),
                arrowprops=dict(arrowstyle="->", color="#1F4E79", lw=1.5), fontsize=7.5, ha="center", va="bottom")

    # 2.0 to 3.0 (Liveness Passed)
    ax.annotate("Liveness Passed\nVerified Token", xy=(6.5, 2.6), xytext=(7.8, 4.4),
                arrowprops=dict(arrowstyle="->", color="#2E7D32", lw=1.5), fontsize=7.5, ha="center", va="bottom")

    # 3.0 to D1
    ax.annotate("Log Tx & Streak", xy=(8.5, 1.9), xytext=(6.7, 1.9),
                arrowprops=dict(arrowstyle="->", color="#334155", lw=1.5), fontsize=7.5, ha="center", va="bottom")

    # 3.0 to User (Receipt)
    ax.annotate("Receipt &\nStatus", xy=(1.4, 4.5), xytext=(5.0, 1.8),
                arrowprops=dict(arrowstyle="->", color="#1F4E79", lw=1.2, connectionstyle="arc3,rad=0.2"), fontsize=7.5, ha="center", va="bottom")

    plt.tight_layout()
    plt.savefig('report_diagrams/dfd_level1_diagram.png', bbox_inches='tight')
    plt.close()
    print("DFD diagram generated.")

def generate_activity_diagram():
    fig, ax = plt.subplots(figsize=(7, 9), dpi=300)
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Start Node
    ax.plot([4.0], [11.5], 'o', markersize=16, color="#0F172A")
    ax.text(4.0, 11.8, "Start", ha="center", va="bottom", fontsize=9, fontweight="bold")
    
    steps = [
        (4.0, 10.5, "Scan Merchant QR Code", "rect", "#E0F2FE"),
        (4.0, 9.3, "Parse Amount (A) & Merchant VPA", "rect", "#E0F2FE"),
        (4.0, 7.8, "Is Amount A > ₹500.00?", "diamond", "#FEF3C7"),
        (6.5, 6.0, "Launch ML Kit Face Detection", "rect", "#FEE2E2"),
        (6.5, 4.8, "Execute Eye-Blink Challenge\n(Open >= 0.70 -> Closed <= 0.25)", "rect", "#FEE2E2"),
        (6.5, 3.6, "Execute Head Yaw Rotation\n(Yaw >= |20 deg|)", "rect", "#FEE2E2"),
        (4.0, 2.2, "Execute Payment Simulator\n(Razorpay Test / Wallet)", "rect", "#DCFCE7"),
        (4.0, 1.0, "Update Balance, Log Receipt\n& Increment Gamified Streak", "rect", "#DCFCE7"),
    ]
    
    for x, y, label, shape, bg in steps:
        if shape == "rect":
            box = patches.FancyBboxPatch((x - 1.5, y - 0.4), 3.0, 0.8, boxstyle="round,pad=0.15",
                                         edgecolor="#334155", facecolor=bg, linewidth=1.2)
            ax.add_patch(box)
            ax.text(x, y, label, ha="center", va="center", fontsize=7.5, fontweight="semibold", color="#0F172A")
        elif shape == "diamond":
            diamond = patches.Polygon([(x, y + 0.6), (x + 1.6, y), (x, y - 0.6), (x - 1.6, y)],
                                      edgecolor="#B45309", facecolor=bg, linewidth=1.5)
            ax.add_patch(diamond)
            ax.text(x, y, label, ha="center", va="center", fontsize=7.5, fontweight="bold", color="#78350F")

    # Arrows
    # Start to Step 1
    ax.annotate("", xy=(4.0, 10.9), xytext=(4.0, 11.4), arrowprops=dict(arrowstyle="->", lw=1.5))
    # Step 1 to Step 2
    ax.annotate("", xy=(4.0, 9.7), xytext=(4.0, 10.1), arrowprops=dict(arrowstyle="->", lw=1.5))
    # Step 2 to Decision
    ax.annotate("", xy=(4.0, 8.4), xytext=(4.0, 8.9), arrowprops=dict(arrowstyle="->", lw=1.5))
    
    # Decision NO (<= 500) -> Direct to Payment
    ax.annotate("NO (A <= 500)\nDirect Sandbox Flow", xy=(4.0, 2.6), xytext=(2.2, 7.8),
                arrowprops=dict(arrowstyle="->", color="#1F4E79", lw=1.5, connectionstyle="arc3,rad=-0.4"),
                fontsize=7.5, fontweight="bold", color="#1F4E79")
    
    # Decision YES (> 500) -> Step 4
    ax.annotate("YES (A > 500)\nMandatory Face Auth", xy=(6.5, 6.4), xytext=(5.6, 7.8),
                arrowprops=dict(arrowstyle="->", color="#B91C1C", lw=1.5, connectionstyle="arc3,rad=0.2"),
                fontsize=7.5, fontweight="bold", color="#B91C1C")
    
    # Step 4 to Step 5
    ax.annotate("", xy=(6.5, 5.2), xytext=(6.5, 5.6), arrowprops=dict(arrowstyle="->", lw=1.5))
    # Step 5 to Step 6
    ax.annotate("", xy=(6.5, 4.0), xytext=(6.5, 4.4), arrowprops=dict(arrowstyle="->", lw=1.5))
    # Step 6 to Step 7
    ax.annotate("Liveness Passed", xy=(4.5, 2.6), xytext=(6.5, 3.2),
                arrowprops=dict(arrowstyle="->", color="#15803D", lw=1.5, connectionstyle="arc3,rad=0.2"),
                fontsize=7.5, fontweight="bold", color="#15803D")

    # Step 7 to Step 8
    ax.annotate("", xy=(4.0, 1.4), xytext=(4.0, 1.8), arrowprops=dict(arrowstyle="->", lw=1.5))
    
    # End Node
    ax.plot([4.0], [0.2], 'o', markersize=16, color="#0F172A")
    ax.plot([4.0], [0.2], 'o', markersize=10, color="#FFFFFF")
    ax.annotate("", xy=(4.0, 0.4), xytext=(4.0, 0.6), arrowprops=dict(arrowstyle="->", lw=1.5))
    ax.text(4.0, -0.05, "End", ha="center", va="top", fontsize=9, fontweight="bold")

    plt.tight_layout()
    plt.savefig('report_diagrams/activity_workflow_diagram.png', bbox_inches='tight')
    plt.close()
    print("Activity Workflow diagram generated.")

if __name__ == '__main__':
    generate_use_case_diagram()
    generate_dfd_diagram()
    generate_activity_diagram()
