#!/usr/bin/env python3
# Copyright 2025 Canonical Ltd.
# See LICENSE file for licensing details.

"""Charm the application."""

import json
import logging

import ops

logger = logging.getLogger(__name__)

ACTION = 'basic-action'
CONTAINER = 'basic-container'
RELATION = 'replicas'


class BasicCharm(ops.CharmBase):
    """Charm the application."""

    def __init__(self, framework: ops.Framework):
        super().__init__(framework)
        framework.observe(self.on[CONTAINER].pebble_ready, self._on_pebble_ready)
        framework.observe(self.on[ACTION].action, self._on_action)
        for event in (
            self.on.config_changed,
            self.on.start,
            self.on.leader_elected,
            self.on[CONTAINER].pebble_ready,
            self.on[ACTION].action,
            self.on[RELATION].relation_created,
            self.on[RELATION].relation_joined,
            self.on[RELATION].relation_changed,
            self.on[RELATION].relation_departed,
            self.on[RELATION].relation_broken,
        ):
            framework.observe(event, self._debug)

    def _on_pebble_ready(self, event: ops.PebbleReadyEvent):
        """Handle pebble-ready event."""
        self.unit.status = ops.ActiveStatus()

    def _on_action(self, event: ops.ActionEvent):
        raw = event.params['data']
        logger.critical(f'_on_action: data={raw}')
        data = json.loads(raw)
        rel = self.model.get_relation(RELATION)
        assert rel is not None
        if data is None:
            action = 'get'
        else:
            action = 'set'
            assert isinstance(data, dict)
            rel.data[self.unit] = data
        result = dict(rel.data[self.unit])
        logger.critical(f'_on_action: result={result}')
        event.set_results({action: str(result)})

    def _debug(self, event: ops.EventBase):
        rel = self.model.get_relation(RELATION)
        rel_data = dict(rel.data[self.unit]) if rel is not None else None
        logger.critical(f'_debug {type(event).__name__} {rel_data}')


if __name__ == '__main__':  # pragma: nocover
    ops.main(BasicCharm)
