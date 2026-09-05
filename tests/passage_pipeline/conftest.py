import pytest


def pytest_configure(config):
    config.addinivalue_line("markers", "network: hits real sites; run with -m network")


def pytest_collection_modifyitems(config, items):
    if config.getoption("-m"):
        return
    skip = pytest.mark.skip(reason="network test; pass -m network to run")
    for item in items:
        if "network" in item.keywords:
            item.add_marker(skip)
