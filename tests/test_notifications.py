import sys
from pathlib import Path
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "shell"))
from model import Notifications


class NotificationTests(unittest.TestCase):
    def test_replace_preserves_identity_and_refreshes_order(self):
        store = Notifications()
        first, _ = store.add(0, "app", "old", "body")
        second, _ = store.add(0, "app", "second", "body")
        ident, evicted = store.add(first, "app", "updated", "body")
        self.assertEqual(ident, first)
        self.assertIsNone(evicted)
        self.assertEqual(list(store.items), [second, first])
        self.assertEqual(store.items[first][1], "updated")

    def test_unknown_replacement_gets_new_id(self):
        store = Notifications()
        ident, _ = store.add(500, "app", "title", "body")
        self.assertEqual(ident, 1)

    def test_flood_is_bounded_and_eviction_reported(self):
        store = Notifications(limit=2)
        for i in range(100):
            ident, evicted = store.add(0, "a" * 1000, "t" * 1000, "b" * 10000)
        self.assertEqual(len(store.items), 2)
        self.assertEqual(evicted, 98)
        self.assertEqual(tuple(map(len, store.items[ident])), (100, 160, 1000))

    def test_close_is_idempotent_and_markup_stays_plain_text(self):
        store = Notifications()
        ident, _ = store.add(0, "app", "<b>literal</b>", "$(touch /tmp/no)")
        self.assertEqual(store.items[ident][1], "<b>literal</b>")
        self.assertTrue(store.close(ident))
        self.assertFalse(store.close(ident))


if __name__ == "__main__":
    unittest.main()
