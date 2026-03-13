from loguru import logger
from ..libraries.custom_logger import tqdm_logging
import pytest
pytest.mark.order(10)

def test_tqdm_logging():
    with tqdm_logging():
        logger.info("1 This is an info message inside tqdm context.")

    logger.success("1 All good?")

    with tqdm_logging():
        logger.info("2 This is an info message inside tqdm context.")

    logger.success("2 All good?")