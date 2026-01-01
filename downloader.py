#!/usr/bin/env python

import re, json, os  
import requests as rq
from typing import Final
from io import StringIO
import pandas as pd
import argparse
from signal import SIGINT, signal

def handler(signal, sigint):
    exit(1)

signal(SIGINT, handler)


s = rq.Session()

def get_gid(url: str) -> list[tuple[str, str]] | None:
    rsp = s.get(url=url)
    regex = re.compile(r'\\"(\d+)\\",\[{\\"\d+\\":\[\[\d+,\d+,\\"(.*?)\\"\]')

    for text in rsp.text.split("\n"):
        match = regex.findall(text)
        if match:
            return match

def download_raw_csv(doc_id: str, gid: str) -> str:
    url = f"https://docs.google.com/spreadsheets/d/{doc_id}/export?format=csv&gid={gid}"
    rsp = s.get(url)
    return rsp.content.decode('utf-8-sig')

match = re.compile(r",{4,}")

def process_csv(csv: str):
    data: str = ""
    for text in csv.split("\n"):
        if not match.search(text):
            data += text + "\n"
    return data

KEY_MAP = {
    "Máquina": "nombre",
    "Dirección IP": "ip",
    "Sistema Operativo": "sistemaOperativo",
    "Dificultad": "dificultad",
    "Técnicas Vistas": "tecnicas",
    "Like": "certificaciones",
    "Writeup": "videoUrl"
}

BLACKLIST = ("Resuelta")

def transform_rows(rows: list[dict]) -> list[dict]:
    final = []

    for row in rows:
        nuevo = {}

        for k, v in row.items():
            if k in BLACKLIST:
                continue
        
            if isinstance(v, str):
                v = "\n".join([line.strip() for line in v.split("\n") if line.strip()])


            if k in KEY_MAP:
                nuevo[KEY_MAP[k]] = v



            else:
                nuevo[k] = v

        final.append(nuevo)

    return final

def parse_path(path: str) -> str:
    
    return os.path.abspath(os.path.expanduser(os.path.expandvars(path)))

def get_path() -> str:

    parser = argparse.ArgumentParser(description="Herramienta escrita en Python para extraer máquinas especificamente de HackTheBox que s4vitar va resolviendo.")
    parser.add_argument('--path',
                        '--path=',
                        type=str,
                        required=True)     
    
    args = parser.parse_args()

    path = parse_path(path=args.path)

    return path 


def main() -> None:

    path = get_path() 

    url: Final[str] = "https://docs.google.com/spreadsheets/d/1dzvaGlT_0xnT-PGO27Z_4prHgA8PHIpErmoWdlUrSoA/"
    doc_id = url.split("/d/")[1].split("/")[0]

    data = get_gid(url)
    if not data:
        return

    tab = data[0][1]
    gid = data[0][0]

    content = download_raw_csv(doc_id=doc_id, gid=gid)
    csv = StringIO(process_csv(csv=content))

    df = pd.read_csv(csv)

    rows = df.to_dict(orient="records")

    rows = transform_rows(rows)

    json_out = json.dumps({"tutorials": rows}, ensure_ascii=False, indent=4)

    with open(path, 'w', encoding="utf-8") as f:
        f.write(json_out)

if __name__ == "__main__":
    main()
