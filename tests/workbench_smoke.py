"""Explicit GTK integration smoke: run inside a disposable graphical session."""
from pathlib import Path
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'workbench'))
from main import Workbench, GLib

app = Workbench()
failures = []

def verify():
    try:
        app.search.set_text('DNS')
        app.refresh_tools()
        assert len(app.rows.get_children()) == 1
        app.search.set_text('nothing-matches-this')
        app.refresh_tools()
        assert 'No matching' in app.rows.get_children()[0].get_child().get_text()
        app.search.set_text('')
        app.refresh_tools()
        assert len(app.rows.get_children()) == 20
        app.stack.set_visible_child_name('Engagements')
        assert app.name.get_placeholder_text()
        app.stack.set_visible_child_name('System checks')
        app.refresh_checks()
        app.stack.set_visible_child_name('Toolkit')
    except Exception as error:
        failures.append(error)
    GLib.timeout_add_seconds(4, finish)
    return False


def finish():
    if app.checks_busy:
        return True
    app.quit()
    return False

GLib.timeout_add(500, verify)
app.run([sys.argv[0]])
app.pool.shutdown(wait=True)
if failures:
    raise failures[0]
print('Workbench GTK smoke passed: search, empty state, navigation, diagnostics.')
