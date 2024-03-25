from __future__ import annotations

import pytest


@pytest.fixture()
def some_string() -> str:
    return "some string"


@pytest.fixture(autouse=True, scope="session")
def some_string2() -> str:
    return "some string2"
