#!/usr/bin/env python3
"""
Split Shigley's Mechanical Engineering Design (11th Ed., Spanish) PDF
into individual PDFs for front matter, each chapter, appendices, and index.
Requires: pypdf (`pip install pypdf`)
"""
import os
import sys
import pypdf

SECTIONS = [
    ("00_Introduccion_Preliminares_y_Contenido.pdf", 1, 20),
    ("01_Parte_1_y_Cap_01_Introduccion_al_diseno_en_ingenieria_mecanica.pdf", 21, 56),
    ("02_Cap_02_Materiales.pdf", 57, 103),
    ("03_Cap_03_Analisis_de_carga_y_esfuerzo.pdf", 104, 177),
    ("04_Cap_04_Deflexion_y_rigidez.pdf", 178, 239),
    ("05_Parte_2_y_Cap_05_Fallas_resultantes_de_carga_estatica.pdf", 240, 281),
    ("06_Cap_06_Fallas_por_fatiga_debidas_a_cargas_variables.pdf", 282, 362),
    ("07_Parte_3_y_Cap_07_Ejes_y_componentes_de_ejes.pdf", 363, 408),
    ("08_Cap_08_Tornillos_sujetadores_y_juntas_no_permanentes.pdf", 409, 468),
    ("09_Cap_09_Soldadura_adhesion_y_uniones_permanentes.pdf", 469, 506),
    ("10_Cap_10_Resortes_mecanicos.pdf", 507, 553),
    ("11_Cap_11_Cojinetes_de_contacto_rodante.pdf", 554, 597),
    ("12_Cap_12_Lubricacion_y_cojinetes_de_deslizamiento.pdf", 598, 651),
    ("13_Cap_13_Engranes_descripcion_general.pdf", 652, 707),
    ("14_Cap_14_Engranes_rectos_y_helicoidales.pdf", 708, 757),
    ("15_Cap_15_Engranes_conicos_y_de_tornillo_sinfin.pdf", 758, 794),
    ("16_Cap_16_Embragues_frenos_acoplamientos_y_volantes.pdf", 795, 842),
    ("17_Cap_17_Elementos_mecanicos_flexibles.pdf", 843, 892),
    ("18_Cap_18_Estudio_de_casos_sobre_transmision_de_potencia.pdf", 893, 911),
    ("19_Parte_4_y_Cap_19_Analisis_de_elemento_finito.pdf", 912, 932),
    ("20_Cap_20_Dimensionamiento_y_tolerancia_geometricos.pdf", 933, 972),
    ("21_Apendice_A_Tablas_utiles.pdf", 973, 1028),
    ("22_Apendice_B_Respuestas_a_problemas_seleccionados.pdf", 1029, 1034),
    ("23_Indice.pdf", 1035, 1058),
]

def split_pdf(input_path: str, output_dir: str = "shigley_split_pdfs"):
    reader = pypdf.PdfReader(input_path)
    os.makedirs(output_dir, exist_ok=True)
    for filename, start_page, end_page in SECTIONS:
        writer = pypdf.PdfWriter()
        for page_idx in range(start_page - 1, end_page):
            writer.add_page(reader.pages[page_idx])
        with open(os.path.join(output_dir, filename), "wb") as out_f:
            writer.write(out_f)
    print(f"Done! Created {len(SECTIONS)} PDFs in '{output_dir}/'.")

if __name__ == "__main__":
    pdf_file = sys.argv[1] if len(sys.argv) > 1 else "Diseno_en_ingenieria_mecanica_de_Shigley.pdf"
    split_pdf(pdf_file)
