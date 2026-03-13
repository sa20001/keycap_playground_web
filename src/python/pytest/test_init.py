from ..libraries import logger_init
import pytest
pytest.mark.order(1)

def test_init():
    logger_init()