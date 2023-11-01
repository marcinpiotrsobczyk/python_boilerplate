from __future__ import annotations

import asyncio
import logging

from python_boilerplate.__private.one import get_hello_string


async def _main() -> None:
    s = get_hello_string()
    logging.error("using python_boilerplate cli")
    logging.error(s)


def main() -> None:
    asyncio.run(_main())


if __name__ == "__main__":
    main()
