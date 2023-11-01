from __future__ import annotations
import logging

import asyncio

from python_boilerplate.__private.one import get_hello_string


async def _main() -> None:
    str = get_hello_string()
    logging.error(f"using python_boilerplate cli")
    logging.error(str)


def main() -> None:
    asyncio.run(_main())


if __name__ == "__main__":
    main()
