import json
from pathlib import Path


def load_state(path=None):
    if path is None:
        path = Path(__file__).resolve().parents[2] / 'ATLAS_STATE.json'
    else:
        path = Path(path)

    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding='utf-8'))
