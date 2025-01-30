# SPDX-FileCopyrightText: (c) 2024 Xronos Inc.
# SPDX-License-Identifier: BSD-3-Clause

from dataclasses import dataclass, field
from typing import Dict

import time

@dataclass
class InfluxLine:
    measurement: str
    tags: Dict[str, str] = field(default_factory=dict)
    fields: Dict[str, str] = field(default_factory=dict)
    timestamp_ns: int = time.time_ns()

    def to_influxdb_line(self) -> str:
        """
        Converts the data record into an InfluxDB line protocol format.
        
        Returns:
        str: A string formatted according to InfluxDB line protocol.
        """
        # Format the tags
        tags = ','.join([f"{key}={value}" for key, value in self.tags.items()])
        # Format the fields
        fields = ','.join([f"{key}={value}" for key, value in self.fields.items()])

        # Combine measurement, tags, fields, and timestamp
        return f"{self.measurement},{tags} {fields} {self.timestamp_ns}"
