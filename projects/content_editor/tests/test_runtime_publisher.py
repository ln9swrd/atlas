import unittest, tempfile, shutil, json, hashlib, sqlite3, sys, os
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
import publish_runtime_package as publisher

ROOT = Path(__file__).resolve().parents[1]

class RuntimePublisherIntegrationTest(unittest.TestCase):
    def test_publish_isolated_filtered_package(self):
        source_db = ROOT / 'data' / 'content_editor.sqlite'
        maps_dir = ROOT / 'data' / 'maps'
        runtime_root_value = os.environ.get('MENOS_RUNTIME_ROOT', '').strip()
        self.assertTrue(runtime_root_value, 'Set MENOS_RUNTIME_ROOT explicitly to the Runtime project path')
        runtime_root = Path(runtime_root_value).resolve()
        before_db = publisher.sha256_file(source_db)
        before_maps = {p.name: publisher.sha256_file(p) for p in maps_dir.glob('*.json')}
        with tempfile.TemporaryDirectory(prefix='menos-publisher-test-') as tmp:
            output = Path(tmp) / 'package'
            result = publisher.publish(source_db, maps_dir, runtime_root, output)
            self.assertTrue((output / 'manifest.json').is_file())
            self.assertTrue((output / 'content' / 'menos.sqlite').is_file())
            manifest = json.loads((output / 'manifest.json').read_text(encoding='utf-8'))
            self.assertEqual(manifest['database']['sha256'], publisher.sha256_file(output / 'content' / 'menos.sqlite'))
            self.assertIn('map_documents', manifest['database']['included_tables'])
            self.assertIn('runtime_settings', manifest['database']['included_tables'])
            self.assertEqual({x['map_id'] for x in manifest['maps']}, {'northbridge_sector_01', 'map_02', 'map_03'})
            self.assertTrue(any(x['code'] == 'UNSUPPORTED_PLAY_MODE_IGNORED' for x in manifest['warnings']))
            for asset in manifest['assets']:
                rel = asset['path'][6:] if asset['path'].startswith('res://') else asset['path']
                path = output.joinpath(*Path(rel).parts)
                self.assertTrue(path.is_file(), asset['path'])
                self.assertEqual(publisher.sha256_file(path), asset['sha256'])
            db = sqlite3.connect('file:%s?mode=ro' % (output / 'content' / 'menos.sqlite').resolve().as_posix(), uri=True)
            try:
                self.assertEqual(db.execute('PRAGMA integrity_check').fetchone()[0], 'ok')
                tables = {r[0] for r in db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")}
                self.assertTrue({'map_documents', 'runtime_settings', 'map_01', 'map_02', 'map_03', 'campaign', 'stage_01'} <= tables)
                runtime_settings = json.loads(db.execute('SELECT raw_json FROM runtime_settings').fetchone()[0])
                self.assertIn('title_screen', runtime_settings)
                self.assertEqual(set(manifest['database']['included_tables']), tables)
                self.assertFalse({'editor', 'player_profile', 'schema_migrations'} & tables)
                for map_id, raw in db.execute('SELECT map_id, raw_json FROM map_documents'):
                    self.assertEqual(json.loads(raw)['map_id'], map_id)
                self.assertEqual(json.loads(db.execute('SELECT raw_json FROM map_01').fetchone()[0])['map_id'], 'northbridge_sector_01')
            finally:
                db.close()
            with self.assertRaises(publisher.PublishError):
                publisher.publish(source_db, maps_dir, runtime_root, output)
        self.assertEqual(before_db, publisher.sha256_file(source_db))
        self.assertEqual(before_maps, {p.name: publisher.sha256_file(p) for p in maps_dir.glob('*.json')})
        self.assertEqual(result['map_count'], 3)

if __name__ == '__main__':
    unittest.main(verbosity=2)
