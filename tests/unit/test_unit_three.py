from __future__ import annotations

import logging
import warnings
from pathlib import Path

from bs4 import BeautifulSoup, XMLParsedAsHTMLWarning


def test_case_beautifulsoup() -> None:
    warnings.filterwarnings("ignore", category=XMLParsedAsHTMLWarning

    logging.error("from unit_one suite")
    example_file_path = Path(__file__).parent / "example.xml"
    with open(example_file_path) as file:
        soup = BeautifulSoup(file)
    
    logging.debug("example debug log")


def test_case_beautifulsoup_htmlparser() -> None:
    logging.error("from unit_one suite")
    example_file_path = Path(__file__).parent / "example.xml"
    with open(example_file_path) as file:
        soup = BeautifulSoup(file, features="html.parser")
    
    logging.debug("example debug log")
