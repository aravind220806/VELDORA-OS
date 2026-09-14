"""Bounded notification storage; no markup or command execution from messages."""
from collections import OrderedDict


class Notifications:
    def __init__(self, limit=30):
        self.items = OrderedDict()
        self.next_id = 1
        self.limit = limit

    def add(self, replaces, app, title, body):
        ident = replaces if replaces in self.items else self.next_id
        if ident == self.next_id:
            self.next_id += 1
        self.items[ident] = (str(app)[:100], str(title)[:160], str(body)[:1000])
        self.items.move_to_end(ident)
        evicted = None
        if len(self.items) > self.limit:
            evicted, _ = self.items.popitem(last=False)
        return ident, evicted

    def close(self, ident):
        return self.items.pop(ident, None) is not None
