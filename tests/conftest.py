import pytest


@pytest.fixture()
def some_string() -> str:
    return "some string"
