"""The repository's gate: runs every test_* function in tests/, failing on the first error."""
import importlib.util
import pathlib
import sys
import traceback

root = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(root))
failed = 0
ran = 0
for path in sorted((root / "tests").glob("test_*.py")):
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    for name in sorted(dir(module)):
        if name.startswith("test_") and callable(getattr(module, name)):
            ran += 1
            try:
                getattr(module, name)()
            except Exception:
                failed += 1
                print(f"FAIL {path.name}::{name}")
                traceback.print_exc()
print(f"gate: {ran - failed} passed, {failed} failed")
sys.exit(1 if failed or not ran else 0)
