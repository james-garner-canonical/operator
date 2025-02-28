#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

"""Charm the application."""

import json
import logging

import ops

logger = logging.getLogger(__name__)


class BasicCharm(ops.CharmBase):
    """Charm the application."""

    def __init__(self, framework: ops.Framework):
        super().__init__(framework)
        framework.observe(self.on['basic-container'].pebble_ready, self._on_pebble_ready)
        framework.observe(self.on['basic-action'].action, self._on_action)

    def _on_pebble_ready(self, event: ops.PebbleReadyEvent):
        """Handle pebble-ready event."""
        self.unit.status = ops.ActiveStatus()

    def _on_action(self, event: ops.ActionEvent):
        raw = event.params['data']
        logger.critical(raw)
        data = json.loads(raw)
        rel = self.model.get_relation('replicas')
        assert rel is not None
        if data is None:
            action = 'get'
        else:
            action = 'set'
            assert isinstance(data, dict)
            rel.data[self.unit] = data
        result = rel.data[self.unit].items()
        event.set_results({action: str(dict(result))})


if __name__ == '__main__':  # pragma: nocover
    ops.main(BasicCharm)
