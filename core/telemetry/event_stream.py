"""
Atlas DevOS - Real-time Event Telemetry Engine (v2.1)
Captures, streams, and persists platform events, rule check findings, and agent actions.
"""
from dataclasses import dataclass, field, asdict
from typing import Dict, Any, List, Optional, Callable
import os
import json
from datetime import datetime, timezone


@dataclass
class TelemetryEvent:
    event_type: str  # e.g., 'RULE_CHECK', 'AGENT_ACTION', 'TASK_STATUS', 'SYSTEM'
    source: str
    message: str
    data: Dict[str, Any] = field(default_factory=dict)
    timestamp: str = field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


class EventStreamEngine:
    """
    Event Telemetry Engine for streaming and recording Atlas DevOS events in real-time.
    """

    def __init__(self, log_path: Optional[str] = None):
        self.log_path = log_path
        self._subscribers: List[Callable[[TelemetryEvent], None]] = []
        self._event_history: List[TelemetryEvent] = []

    def subscribe(self, callback: Callable[[TelemetryEvent], None]) -> None:
        """Register a subscriber callback for real-time event streaming."""
        self._subscribers.append(callback)

    def publish(self, event_type: str, source: str, message: str, data: Optional[Dict[str, Any]] = None) -> TelemetryEvent:
        """Publish a telemetry event to subscribers and log history."""
        event = TelemetryEvent(
            event_type=event_type,
            source=source,
            message=message,
            data=data or {},
        )
        self._event_history.append(event)

        for sub in self._subscribers:
            try:
                sub(event)
            except Exception:
                pass

        if self.log_path:
            self._write_to_log(event)

        return event

    def _write_to_log(self, event: TelemetryEvent) -> None:
        os.makedirs(os.path.dirname(os.path.abspath(self.log_path)), exist_ok=True)
        with open(self.log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(asdict(event), ensure_ascii=False) + "\n")

    def get_history(self, filter_type: Optional[str] = None) -> List[TelemetryEvent]:
        if not filter_type:
            return list(self._event_history)
        return [e for e in self._event_history if e.event_type == filter_type]
